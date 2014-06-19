# -*- encoding: utf-8 -*-
################################################################################
# Time-stamp: <Ven 2014-06-20 00:10 svarrette>
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
            load 'falkorlib/tasks/yard.rake'
            load 'falkorlib/tasks/rspec.rake'
        end
    end # class FalkorLib::GemTasks
end # module FalkorLib

# Now install them ;)
FalkorLib::GemTasks.new.install_tasks
