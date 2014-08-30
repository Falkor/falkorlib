# -*- encoding: utf-8 -*-
################################################################################
# Time-stamp: <Sat 2014-08-30 14:24 svarrette>
################################################################################
# Interface for the main Puppet Module operations
#

require "falkorlib"
require "falkorlib/common"

require "pathname"
require 'json'

include FalkorLib::Common

module FalkorLib  #:nodoc:
    module Config
        module Puppet
            module Modules
                DEFAULTS = {
                    :metadata => {
                        :name         => '',
                        :version      => '0.0.1',
                        :author       => "#{ENV['GIT_AUTHOR_NAME']}",
                        :mail         => "#{ENV['GIT_AUTHOR_EMAIL']}",
                        :summary      => "rtfm",
                        :description  => '',
                        :license      => 'Apache-2.0',
                        :source       => '',
                        :project_page => '',
                        :issues_url   => '',
                        :dependencies => [],
                        :operatingsystem_support => [],
                        :tags         => []
                    },
                    :licenses => [
                                  "Apache-2.0",
                                  "BSD",
                                  "GPL-2.0",
                                  "GPL-3.0",
                                  "LGPL-2.1",
                                  "LGPL-3.0",
                                  "MIT",
                                  "Mozilla-2.0"
                                 ]
                }
            end
        end
    end

    # Puppet actions
    module Puppet
        # Management of Puppet Modules operations
        module Modules

	        module_function
	                    
            def _get_classdefs(moduledir = Dir.pwd, type = 'classes')
	            name     = File.basename( moduledir )
	            error "The module #{name} does not exist" unless File.directory?( moduledir )
	            t = case type
	                when /class*/i 
		                'class'
	                when /def*/    
		                'define'
	                else 
		                ''		            
	            end
	            error "Undefined type #{type}" if t.empty?	            
                result = []
                Dir["#{moduledir}/manifests/**/*.pp"].each do |ppfile|
		            File.read(ppfile).scan(/^[ \t]*#{t}[\s]+([0-9a-zA-z:-]+).*$/).each do |line|
                        result << line[0]
                    end
                end
                result.uniq!
                result
            end



            ####
            # Initialize a new Puppet Module named `name` in `rootdir`.
            # Supported options:
            # * :no_iteraction [boolean]
            ##
            def init(rootdir = Dir.pwd, name = '', options = {})
                config = {}
                login = `whoami`.chomp
                config[:name] = name unless name.empty?
	            moduledir = name.empty? ? rootdir : File.join(rootdir, name)
                FalkorLib::Config::Puppet::Modules::DEFAULTS[:metadata].each do |k,v|
                    next if v.kind_of?(Array) or k == :license
                    next if k == :name and ! name.empty?
                    default_answer = case k
                                     when :project_page
                                         config[:source].nil? ? v : config[:source]
                                     when :name
                                         File.basename(rootdir).gsub(/^puppet-/, '')
                                     when :issues_url
                                         config[:project_page].nil? ? v : "#{config[:project_page]}/issues"
                                     when :description
                                         config[:summary].nil? ? v : "#{config[:summary]}"
                                     when :source
                                         v.empty? ? "https://github.com/#{`whoami`.chomp}/#{config[:name]}" : v
                                     else
                                         v
                                     end
                    config[k.to_sym] = ask( "\t" + sprintf("%-20s", "Module #{k}"), default_answer)
                end
                name = config[:name].gsub(/.*-/, '')
	            tags = ask("\tKeywords (comma-separated list of tags)", name)
                config[:tags] = tags.split(',')
	            list_license    = FalkorLib::Config::Puppet::Modules::DEFAULTS[:licenses]
	            default_license = FalkorLib::Config::Puppet::Modules::DEFAULTS[:metadata][:license]
	            idx = list_license.index(default_license) unless default_license.nil?
	            license = select_from(list_license,
                                      'Select the license index for the Puppet module:',
	                                  idx.nil? ? 1 : idx + 1)
                config[:license] = license.downcase unless license.empty?
                puts "\t" + sprintf("%-20s", "Module License:") + config[:license]

                #ap config
                # Bootstrap the directory
                templatedir = File.join( FalkorLib.templates, 'puppet', 'modules')
	            init_from_template(templatedir, moduledir, config, {
                                       :erb_exclude => [ 'templates\/[^\/]*\.erb$' ]
                                   })
                # Rename the files / element templatename
                Dir["#{moduledir}/**/*"].each do |e|
                    next unless e =~ /templatename/
                    info "renaming #{e}"
                    newname = e.gsub(/templatename/, "#{name}")
                    run %{ mv #{e} #{newname} }
                end

                info "Generating the License file"
                authors = config[:author].empty? ? 'UNKNOWN' : config[:author]
                Dir.chdir(moduledir) do
                    run %{ licgen #{config[:license]} #{authors} }
                end
                info "Initialize RVM"
                init_rvm(moduledir)
                unless FalkorLib::GitFlow.init?(moduledir)
                    warn "Git [Flow] is not initialized in #{moduledir}."
                    a = ask("Proceed to git-flow initialization (Y|n)", 'Yes')
                    FalkorLib::GitFlow.init(moduledir) unless a =~ /n.*/i
                end

                # Propose to commit the key files
                if FalkorLib::Git.init?(moduledir)
                    if FalkorLib::GitFlow.init?(moduledir)
                        info "=> preparing git-flow feature for the newly created module '#{config[:name]}'"
                        FalkorLib::GitFlow.start('feature', "bootstraping", moduledir)
                    end
                    [ 'metadata.json', 'LICENSE', '.gitignore', 'Gemfile', 'Rakefile'].each do |f|
                        FalkorLib::Git.add(File.join(moduledir, f))
                    end
                end
            end # init

            ####
            # Parse a given modules to collect information
            ##
            def parse(moduledir = Dir.pwd)
                name     = File.basename( moduledir )
                error "The module #{name} does not exist" unless File.directory?( moduledir )
	            jsonfile = File.join( moduledir, 'metadata.json')
	            error "Unable to find #{jsonfile}" unless File.exist?( jsonfile ) 
	            metadata = JSON.parse( IO.read( jsonfile ) )
	            metadata["classes"]     = classes(moduledir)
	            metadata["definitions"] = definitions(moduledir)
	            deps        = deps(moduledir)
	            listed_deps = metadata["dependencies"]
	            missed_deps = []
	            metadata["dependencies"].each do |dep|
		            lib = dep["name"].gsub(/^[^\/-]+[\/-]/,'')
		            if deps.include?( lib )
			            deps.delete( lib ) 
		            else 
			            unless lib =~ /stdlib/
				            warn "The library '#{dep["name"]}' is not analyzed as part of the #{name} module" 
				            missed_deps << dep
			            end 
		            end 
	            end
	            if ! deps.empty?
		            deps.each do |l| 
			            shortname = name.gsub(/.*-/, '')
			            shortmetaname = metadata["name"].gsub(/.*-/, '')
			            next if [name, metadata["name"], name.gsub(/.*-/, ''), metadata["name"].gsub(/.*-/, '') ].include? ( l )  
			            warn "The module '#{l}' is missing in the dependencies thus added"
			            login = ask("[Github] login for the module '#{l}'")
			            version = ask("Version requirement (ex: '>=1.0.0 <2.0.0' or '1.2.3' or '1.x')")
			            metadata["dependencies"] << {
				            "name"                => "#{login}/#{l}",
				            "version_requirement" => "#{version}"
			            }
		            end
	            end
	            info "Metadata configuration for the module '#{name}'"
	            puts JSON.pretty_generate( metadata )
	            warn "About to commit these changes in the '#{name}/metadata.json' file"
	            really_continue?
	            File.open(jsonfile,"w") do |f|
		            f.write JSON.pretty_generate( metadata )
	            end

            end # parse


            #######
            # Find the classes of a given module
            ###
            def classes(moduledir = Dir.pwd)
	            _get_classdefs(moduledir, 'classes')
            end

            #######
            # Find the definitions of a given module
            ###
            def definitions(moduledir = Dir.pwd)
	            _get_classdefs(moduledir, 'definitions')
            end

            #######
            # Find the dependencies of a given module
            ###
            def deps(moduledir = Dir.pwd)
	            name     = File.basename( moduledir )
	            error "The module #{name} does not exist" unless File.directory?( moduledir )

	            result    = Array.new
	            result2   = Array.new
	            resulttmp = Array.new

	            result << name

	            while result != result2 do
		            resulttmp = result.dup
		            (result - result2).each do |x|
			            Dir["#{moduledir}/**/*.pp"].each do |ppfile|
				            File.read(ppfile).scan(/^[ \t]*include.*$|^[ \t]*require.*$/).each do |line|
					            if line.scan(">").length == 0
						            result << line.gsub(/^[ \t]*(include|require) ([\"']|)([0-9a-zA-Z:{$}\-]*)([\"']|)/, '\3').split("::").first
					            end
				            end
			            end
		            end
		            result.uniq!
		            result2 = resulttmp.dup
	            end
	            result.delete "#{name}"
	            result
            end


        end # module FalkorLib::Puppet::Modules
    end # module FalkorLib::Puppet
end # module FalkorLib
