# -*- encoding: utf-8 -*-
################################################################################
# puppet_modules.rake - Special tasks for the management of Puppet modules
# Time-stamp: <Lun 2014-08-25 22:54 svarrette>
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
			FalkorLib::Puppet::Modules.init(dir, name)
		end 


	end # namespace bootstrap:puppet
end # namespace bootstrap

