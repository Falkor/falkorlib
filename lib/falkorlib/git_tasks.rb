# -*- encoding: utf-8 -*-
################################################################################
# Time-stamp: <Ven 2014-06-06 17:05 svarrette>
################################################################################
#
# FalkorLib rake tasks to pilot Git [flow] operations
#

require 'rake'
require 'falkorlib'
require 'falkorlib/tasks'

module FalkorLib #:nodoc:

	# Rake tasks to pilot Git operations 
    class GitTasks
        include Rake::DSL if defined? Rake::DSL

        # Install the git[flow] tasks for Rake
        def install_tasks
	        load 'falkorlib/tasks/git.rake'
            load 'falkorlib/tasks/gitflow.rake'
        end
    end # class FalkorLib::GitTasks
end # module FalkorLib


# Now install them ;)
FalkorLib::GitTasks.new.install_tasks
