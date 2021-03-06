# -*- encoding: utf-8 -*-
################################################################################
# git.rake - Special tasks for the management of Git operations
# Time-stamp: <Fri 2016-11-11 15:41 svarrette>
#
# Copyright (c) 2014 Sebastien Varrette <Sebastien.Varrette@uni.lu>
#               http://varrette.gforge.uni.lu
################################################################################

require 'falkorlib'
require 'falkorlib/tasks'
require 'falkorlib/git'

#.....................
namespace :git do
  include FalkorLib::Common
  git_root_dir = FalkorLib::Git.rootdir
  remotes = FalkorLib::Git.remotes
  #ap remotes


  ###########   git:fetch   ###########
  #desc "Fetch the latest changes on remotes"
  task :fetch do |_t|
    info "Fetch the latest changes on remotes" # t.comment
    FalkorLib::Git.fetch
  end # task fetch

  %w(up push).each do |op|
    description = case op
                  when 'up' then   "Update your local copy of the repository from GIT server"
                  when 'push' then "Push your modifications onto the remote branches"
                  end
    ###########  git:{up,push}  ###########
    #desc "#{description}"
    task op.to_sym do |t|
      info description # t.comment
      if remotes.empty? || !remotes.include?( 'origin' )
        warn "No git remote configured... Exiting #{t}"
        next
      end
      cmd = ( op == 'up') ? 'pull' : op
      branch = FalkorLib::Git.branch?
      if FalkorLib::Git.list_branch.include? "remotes/origin/#{branch}"
        status = run %(
                      git #{cmd} origin
        )
        if (status.to_i.nonzero?)
          warn("The command '#{cmd}' failed with exit status #{status.to_i}")
          warn("This may be due to the fact that you're not connected to the internet")
          really_continue?('no')
        end
      else
        warn "The current branch '#{branch} is not currently tracked on the remote 'origin'."
        warn "=> exiting"
        next
      end
    end
  end

  if (!FalkorLib.config.git[:submodules].empty?) || File.exist?("#{git_root_dir}/.gitmodules")
    #.....................
    namespace :submodules do
      ###########   init   ###########
      desc "Initialize the Git submodules (as defined in FalkorLib.config.git[:submodules] or .gitmodules)"
      task :init do |t|
        info t.full_comment
        FalkorLib::Git.submodule_init(git_root_dir)
      end # task submodules:init
    end # namespace submodules
  end

  if File.exist?("#{git_root_dir}/.gitmodules")
    #.....................
    namespace :submodules do
      ########### git:submodules:update ###########
      #desc "Update the git submodules from '#{git_root_dir}'"
      task :update do |_t|
        info "Update the git submodules from '#{git_root_dir}'" # t.comment
        FalkorLib::Git.submodule_update( git_root_dir )
      end

      ########### git:submodules:upgrade ###########
      desc "Upgrade the git submodules to the latest HEAD commit -- USE WITH CAUTION"
      task :upgrade => [ :update] do |t|
        info t.comment
        FalkorLib::Git.submodule_upgrade( git_root_dir )
      end
    end # namespace git:submodules
  end

  unless FalkorLib.config.git[:subtrees].empty?
    #.....................
    namespace :subtrees do
      ###########   git:subtrees:init  ###########
      desc "Initialize the Git subtrees defined in FalkorLib.config.git[:subtrees]"
      task :init do
        FalkorLib::Git.subtree_init(git_root_dir)
      end # task git:subtree:init

      if FalkorLib::Git.subtree_init?(git_root_dir)
        ###########   git:subtrees:diff   ###########
        desc "Show difference between local subtree(s) and their remotes"
        task :diff do
          FalkorLib::Git.subtree_diff(git_root_dir)
        end # task git:subtree:diff

        ###########   git:subtrees:up   ###########
        desc "Pull the latest changes from the remote to the local subtree(s)"
        task :up do
          FalkorLib::Git.subtree_up(git_root_dir)
        end # task git:subtree:diff
      end
    end # namespace git:subtrees
  end
end # namespace git

task :setup => [ 'git:init' ]
if (!FalkorLib.config.git[:submodules].empty?) || File.exist?("#{FalkorLib::Git.rootdir}/.gitmodules")
  task :setup => [ 'git:submodules:init' ]
end
unless FalkorLib.config.git[:subtrees].empty?
  task :setup => [ 'git:subtrees:init' ]
end
