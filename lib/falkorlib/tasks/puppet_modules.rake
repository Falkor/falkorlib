# -*- encoding: utf-8 -*-
################################################################################
# puppet_modules.rake - Special tasks for the management of Puppet modules
# Time-stamp: <Lun 2014-08-25 15:58 svarrette>
#
# Copyright (c) 2014 Sebastien Varrette <Sebastien.Varrette@uni.lu>
#               http://varrette.gforge.uni.lu
################################################################################

require 'falkorlib'
require 'falkorlib/tasks'
require 'falkorlib/puppet/modules'


#.....................
namespace :bootstrap do
	#.....................
	namespace :puppet do
		
		###########  bootstrap:puppet:module   ###########
		desc "Bootstrap a new Puppet module"
		task :module do |t|
			info "#{t.comment}"
			dstdir = ask("Destination directory:", File.join(Dir.pwd, 'new'))
			FalkorLib::Puppet::Modules.init(dstdir)
		end 


	end # namespace bootstrap:puppet
end # namespace bootstrap

