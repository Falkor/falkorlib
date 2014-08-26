# -*- encoding: utf-8 -*-
################################################################################
# Time-stamp: <Mar 2014-08-26 12:01 svarrette>
################################################################################
# Interface for the main Puppet Module operations
#

require "falkorlib"
require "falkorlib/common"

require "pathname"

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
            module_function

            ## Initialize a new Puppet Module
            def init(rootdir = Dir.pwd, name = '')
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
	            Dir.chdir(rootdir) do 
		            run %{licgen #{config[:license]} #{config[:author]}}
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


        end # module FalkorLib::Puppet::Modules
    end # module FalkorLib::Puppet
end # module FalkorLib
