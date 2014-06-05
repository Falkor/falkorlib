##############################################################################
# git_tasks : FalkorLib rake tasks to pilot Git [flow] operations
# .           See http://rake.rubyforge.org/
# Time-stamp: <Jeu 2014-06-05 10:50 svarrette>
#
# Copyright (c) 2014 Sebastien Varrette <Sebastien.Varrette@uni.lu>
##############################################################################

require 'rake'

module FalkorLib
    class GitTasks
        include Rake::DSL if defined? Rake::DSL

        # Install the git[flow] tasks for Rake
        def install_tasks
            load 'falkorlib/tasks/gitflow.rake'
        end
    end # class FalkorLib::GitTasks
end # module FalkorLib

FalkorLib::GitTasks.new.install_tasks
