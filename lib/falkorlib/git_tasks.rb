# -*- encoding: utf-8 -*-
################################################################################
# Time-stamp: <Mar 2014-06-10 10:31 svarrette>
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


if FalkorLib::Git.init?
	# Now install them ;)
	FalkorLib::GitTasks.new.install_tasks
else 
	warn "Git is not initialized for this directory."
	warn "==> consider running 'git init' to be able to access the git Rake tasks"
	#.....................
	namespace :git do
		###########  git:init   ###########
		desc "Initialize Git repository"
		task :init do 
			FalkorLib::Git.init
		end  

	end # namespace git


end
