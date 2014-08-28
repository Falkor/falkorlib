# -*- encoding: utf-8 -*-
################################################################################
# Time-stamp: <Thu 2014-08-28 15:20 svarrette>
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
                        :license      => 'GPLv3',
                        :source       => '',
                        :project_page => '',
                        :issue_url    => '',
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
		            File.read(ppfile).scan(/^[ \t]*#{t}[\s]+([0-9a-zA-z:]+).*$/).each do |line|
                        result << line[0]
                    end
                end
                result.uniq!
                result
            end

            module_function

            ####
            # Initialize a new Puppet Module named `name` in `rootdir`.
            # Supported options:
            # * :no_iteraction [boolean]
            ##
            def init(rootdir = Dir.pwd, name = '', options = {})
                config = {}
                login = `whoami`.chomp
                config[:name] = name unless name.empty?
                FalkorLib::Config::Puppet::Modules::DEFAULTS[:metadata].each do |k,v|
                    next if v.kind_of?(Array) or k == :license
                    next if k == :name and ! name.empty?
                    default_answer = case k
                                     when :project_page
                                         config[:source].nil? ? v : config[:source]
                                     when :name
                                         File.basename(rootdir).gsub(/^puppet-/, '')
                                     when :issue_url
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
                license = select_from(FalkorLib::Config::Puppet::Modules::DEFAULTS[:licenses],
                                      'Select the license index for the Puppet module:',
                                      1)
                config[:license] = license.downcase unless license.empty?
                puts "\t" + sprintf("%-20s", "Module License:") + config[:license]

                #ap config
                # Bootstrap the directory
                templatedir = File.join( FalkorLib.templates, 'puppet', 'modules')
                init_from_template(templatedir, rootdir, config, {
                                       :erb_exclude => [ 'templates\/[^\/]*\.erb$' ]
                                   })
                # Rename the files / element templatename
                Dir["#{rootdir}/**/*"].each do |e|
                    next unless e =~ /templatename/
                    info "renaming #{e}"
                    newname = e.gsub(/templatename/, "#{name}")
                    run %{ mv #{e} #{newname} }
                end

                info "Generating the License file"
                authors = config[:author].empty? ? 'UNKNOWN' : config[:author]
                Dir.chdir(rootdir) do
                    run %{ licgen #{config[:license]} #{authors} }
                end
                info "Initialize RVM"
                init_rvm(rootdir)
                unless FalkorLib::GitFlow.init?(rootdir)
                    warn "Git [Flow] is not initialized in #{rootdir}."
                    a = ask("Proceed to git-flow initialization (Y|n)", 'Yes')
                    FalkorLib::GitFlow.init(rootdir) unless a =~ /n.*/i
                end

                # Propose to commit the key files
                if FalkorLib::Git.init?(rootdir)
                    if FalkorLib::GitFlow.init?(rootdir)
                        info "=> preparing git-flow feature for the newly created module '#{config[:name]}'"
                        FalkorLib::GitFlow.start('feature', "init_#{name}", rootdir)
                    end
                    [ 'metadata.json', 'LICENSE', '.gitignore', 'Gemfile', 'Rakefile'].each do |f|
                        FalkorLib::Git.add(File.join(rootdir, f))
                    end
                end
            end # init

            ####
            # Parse a given modules to collect information
            ##
            def parse(moduledir = Dir.pwd)
                name     = File.basename( moduledir )
                jsonfile = File.join( moduledir, 'metadata.json')
                error "The module #{name} does not exist" unless File.directory?( moduledir )
                error "Unable to find #{jsonfile}" unless File.exist?( metadata )
                metadata = JSON.parse( IO.read( jsonfile ) )
	            

                ap metadata
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
