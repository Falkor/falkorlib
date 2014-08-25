# -*- encoding: utf-8 -*-
################################################################################
# Time-stamp: <Lun 2014-08-25 21:46 svarrette>
################################################################################
#
# FalkorLib rake tasks to pilot Puppet operations
#

require 'rake'
require 'falkorlib'
require 'falkorlib/tasks'

module FalkorLib #:nodoc:
	class PuppetTasks
		include Rake::DSL if defined? Rake::DSL

		# Install the puppet tasks for Rake
        def install_tasks
            load 'falkorlib/tasks/puppet_modules.rake'
        end
	end
end

FalkorLib::PuppetTasks.new.install_tasks
