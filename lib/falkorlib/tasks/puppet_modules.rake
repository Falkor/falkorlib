# -*- encoding: utf-8 -*-
################################################################################
# puppet_modules.rake - Special tasks for the management of Puppet modules
# Time-stamp: <Lun 2014-09-01 16:38 svarrette>
#
# Copyright (c) 2014 Sebastien Varrette <Sebastien.Varrette@uni.lu>
#               http://varrette.gforge.uni.lu
################################################################################

require 'falkorlib'
require 'falkorlib/tasks'
require 'falkorlib/puppet'

#.....................
namespace :bootstrap do
    #.....................
    namespace :puppet do

        ###########  bootstrap:puppet:module   ###########
        desc "Bootstrap a new Puppet module"
        task :module, [:name] do |t, args|
            info "#{t.comment}"
            name = args.name == 'name' ? ask("Enter the module name") : args.name
            error "You need to provide a module name" unless name != ''
            error "The module name cannot contain spaces" if name =~ /\s+/
            moduledir = File.join( FalkorLib.config[:puppet][:modulesdir], name)
            dir = ask("Destination directory:", moduledir)
            error "The module '#{name}' already exists" if File.directory?(dir)
            FalkorLib::Puppet::Modules.init(dir)
        end


    end # namespace bootstrap:puppet
end # namespace bootstrap

require 'json'

#.....................
namespace :puppet do
    include FalkorLib::Common

    if command?('puppet')
        #.....................
        namespace :module do

            ###########   puppet:module:build   ###########
            desc "Build the puppet module to publish it on the Puppet Forge"
            task :build do |t|
                info "#{t.comment}"
                run %{ puppet module build }
				if File.exists? ('metadata.json')
					metadata = JSON.parse( IO.read( 'metadata.json' ) )
					name    = metadata["name"]
					version = metadata["version"]
					url = metadata["forge_url"].nil? ? "https://forge.puppetlabs.com/#{name.gsub(/-/,'/')}" : metadata["forge_url"]
					warn "you can now upload the generated file 'pkg/#{name}-#{version}.tar.gz' on the puppet forge"
					warn "         #{url}"
				end 
            end # task build

            ###########   puppet:module:parse   ###########
            desc "Parse a given module"
            task :parse do |t|
                info "#{t.comment}"
                FalkorLib::Puppet::Modules.parse()
            end # task parse

			###########   puppet:module:validate   ###########
			desc "Validate manifests, templates, and ruby files"
			task :validate do
				Dir['manifests/**/*.pp'].each do |manifest|
					sh "puppet parser validate --noop #{manifest}"
				end
				Dir['spec/**/*.rb','lib/**/*.rb'].each do |ruby_file|
					sh "ruby -c #{ruby_file}" unless ruby_file =~ /spec\/fixtures/
				end
				Dir['templates/**/*.erb'].each do |template|
					sh "erb -P -x -T '-' #{template} | ruby -c"
				end
			end
			
			###########   puppet:module:classes   ###########
			desc "Parse the module for classes definitions"
			task :classes do |t|
				c = FalkorLib::Puppet::Modules.classes()
				info "Implemented classes:"
				puts c.empty? ? red('NONE') : c.to_yaml				
			end # task classes 

			###########   puppet:module:definitions   ###########
			desc "Parse the module for definitions"
			task :definitions do |t|
				d = FalkorLib::Puppet::Modules.definitions()
				info "Implemented definitions:"
				puts d.empty? ? red('NONE') : d.to_yaml				
			end # task definitions

			###########   puppet:module:deps   ###########
			desc "Parse the module for its exact dependencies"
			task :deps do |t|
				d = FalkorLib::Puppet::Modules.deps()
				info "Module dependencies:"
				puts d.empty? ? red('NONE') : d.to_yaml				
			end # task deps


        end
    end # namespace module
end # namespace puppet

#.....................
namespace :templates do
	namespace :upgrade do
		###########   module:upgrade:readme   ###########
		task :readme do |t|
			#info "#{t.comment}"
			FalkorLib::Puppet::Modules.upgrade()
		end 
	end # namespace upgrade
end # namespace module

[ 'major', 'minor', 'patch' ].each do |level|
	task "version:bump:#{level}" => 'puppet:module:validate'
end 

#task 'version:release' => 'puppet:module:build'
Rake::Task["version:release"].enhance do
  Rake::Task["puppet:module:build"].invoke
end
