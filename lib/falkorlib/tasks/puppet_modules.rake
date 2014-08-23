# -*- encoding: utf-8 -*-
################################################################################
# puppet_modules.rake - Special tasks for the management of Puppet modules
# Time-stamp: <Sam 2014-08-23 15:47 svarrette>
#
# Copyright (c) 2014 Sebastien Varrette <Sebastien.Varrette@uni.lu>
#               http://varrette.gforge.uni.lu
################################################################################

require 'falkorlib'
require 'falkorlib/tasks'

#.....................
namespace :puppet do

	#.....................
	namespace :module do
		

		###########  puppet:module:bootstrap   ###########
		desc "Bootstrap a new module"
		task :bootstrap do |t|
			info "#{t.comment}"
			

			
		end # task bootstrap 





	end # namespace puppet:module
end # namespace puppet

