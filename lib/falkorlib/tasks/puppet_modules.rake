# -*- encoding: utf-8 -*-
################################################################################
# puppet_modules.rake - Special tasks for the management of Puppet modules
# Time-stamp: <Sat 2014-08-30 21:52 svarrette>
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


        end
    end # namespace module
end # namespace puppet

#.....................
namespace :module do
	namespace :upgrade do
		###########   module:upgrade:readme   ###########
		task :readme do |t|
			#info "#{t.comment}"
			FalkorLib::Puppet::Modules.upgrade()
		end 


	end # namespace upgrade
end # namespace module

task 'version:release' => 'puppet:module:build'
