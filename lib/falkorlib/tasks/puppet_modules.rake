# -*- encoding: utf-8 -*-
################################################################################
# puppet_modules.rake - Special tasks for the management of Puppet modules
# Time-stamp: <Sat 2014-08-30 20:57 svarrette>
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
                warn "you can now upload the generated file on the puppet forge"
                warn "         https://forge.puppetlabs.com/"
            end # task build

            ###########   puppet:module:parse   ###########
            desc "Parse a given module"
            task :parse do |t|
                info "#{t.comment}"
                FalkorLib::Puppet::Modules.parse(TOP_SRCDIR)
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
