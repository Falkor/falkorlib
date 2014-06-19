# -*- encoding: utf-8 -*-
################################################################################
# Time-stamp: <Jeu 2014-06-19 22:14 svarrette>
################################################################################
#
# FalkorLib rake tasks to pilot Gem operations
#

require 'rake'
require 'falkorlib'
require 'falkorlib/tasks'

module FalkorLib #:nodoc:

    # Rake tasks to pilot Gem operations
    class GemTasks
        include Rake::DSL if defined? Rake::DSL

        # Install the gem  tasks for Rake
        def install_tasks
            load 'falkorlib/tasks/gem.rake'
        end
    end # class FalkorLib::GemTasks
end # module FalkorLib

# Now install them ;)
FalkorLib::GemTasks.new.install_tasks
