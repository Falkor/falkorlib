##############################################################################
# git_tasks : FalkorLib rake tasks to pilot Git [flow] operations
# .           See http://rake.rubyforge.org/
# Time-stamp: <Mar 2014-06-03 11:32 svarrette>
#
# Copyright (c) 2014 Sebastien Varrette <Sebastien.Varrette@uni.lu>
##############################################################################

require 'rake'

module FalkorLib
    class GitTasks
        include Rake::DSL if defined? Rake::DSL

        def install_tasks
	        load 'falkorlib/tasks/gitflow.rake'
        end
    end # class FalkorLib::GitTasks
end # module FalkorLib

FalkorLib::GitTasks.new.install_tasks
