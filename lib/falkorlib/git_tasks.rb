##############################################################################
# git_tasks : FalkorLib rake tasks to pilot Git [flow] operations
# .           See http://rake.rubyforge.org/
# Time-stamp: <Ven 2014-06-06 15:34 svarrette>
#
# Copyright (c) 2014 Sebastien Varrette <Sebastien.Varrette@uni.lu>
##############################################################################

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

FalkorLib::GitTasks.new.install_tasks
