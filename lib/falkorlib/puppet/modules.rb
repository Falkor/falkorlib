# -*- encoding: utf-8 -*-
################################################################################
# Time-stamp: <Lun 2014-08-25 23:06 svarrette>
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
                tags = ask("\tKeywords (comma-separated list of tags)", config[:name].gsub(/.*-/, ''))
	            config[:tags] = tags.split(',')
	            license = select_from(FalkorLib::Config::Puppet::Modules::DEFAULTS[:licenses], 
	                                  'Select the licence index for the Puppet module:', 
	                                  1)
	            puts "\tModule Licence:"
	            config[:license] = license.downcase unless license.empty?
	            #ap config
	            # Bootstrap the directory
	            templatedir = File.join( FalkorLib.templates, 'puppet', 'modules')
	            init_from_template(templatedir, rootdir, config, {
		                               :erb_exclude => [ 'templates\/[^\/]*\.erb$' ]
	                               })
	            info "Generating the License file"
	            Dir.chdir(rootdir) do 
		            run %{licgen #{config[:license]} #{config[:author]}}
	            end
	            info "Initialize RVM"
	            init_rvm(rootdir)


            end # init




        end # module FalkorLib::Puppet::Modules
    end # module FalkorLib::Puppet
end # module FalkorLib
