# -*- encoding: utf-8 -*-
################################################################################
# Time-stamp: <Wed 2018-10-03 21:57 svarrette>
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
  warn "==> consider running 'rake git[:flow]:init' to be able to access the regular git Rake tasks"
  #.....................
  namespace :git do
    ###########  git:init   ###########
    desc "Initialize Git repository"
    task :init do
      FalkorLib::Git.init
    end

    #.....................
    namespace :flow do
      ###########  git:flow:init   ###########
      desc "Initialize the Git-flow repository"
      task :init do
        FalkorLib::GitFlow.init
      end
    end # namespace git:flow
  end # namespace git
end

###########   up   ###########
desc "upgrade your local branche(s)"
task :up do |t|
  if   FalkorLib::GitFlow.init?
    Rake::Task['git:flow:up'].invoke
  else
    Rake::Task['git:up'].invoke
  end
end # task up
