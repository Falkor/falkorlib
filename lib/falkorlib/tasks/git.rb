# -*- encoding: utf-8 -*-
################################################################################
# Time-stamp: <Fri 2016-11-11 14:29 svarrette>
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

    if   FalkorLib::GitFlow.init?
      ###########  git:up   ###########
      desc "Update your local branches"
      task :up do |t|
        info "#{t.comment}"
        FalkorLib::Git.fetch
        branches = FalkorLib::Git.list_branch
        #puts branches.to_yaml
        unless FalkorLib::Git.dirty?
          FalkorLib.config.gitflow[:branches].each do |t, br|
            info "updating Git Flow #{t} branch '#{br}' with the 'origin' remote"
            run %{ git checkout #{br} && git merge origin/#{br} }
          end
          run %{ git checkout #{branches[0]} }  # Go back to the initial branch
        else
          warning "Unable to update -- your local repository copy is dirty"
        end
      end # task git:up
    end
  end # namespace git
end
