# -*- encoding: utf-8 -*-
################################################################################
# Time-stamp: <Fri 2016-11-11 14:45 svarrette>
################################################################################
#
# FalkorLib rake tasks to pilot Puppet operations
#

require 'rake'
require 'falkorlib'
require 'falkorlib/tasks'

module FalkorLib #:nodoc:
  # Puppet tasks for Rake
  class PuppetTasks

    include Rake::DSL if defined? Rake::DSL

    # Install the puppet tasks for Rake
    def install_tasks
      load 'falkorlib/tasks/puppet_modules.rake'
    end

  end
end

FalkorLib::PuppetTasks.new.install_tasks
