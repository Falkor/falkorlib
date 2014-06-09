# -*- encoding: utf-8 -*-
################################################################################
# git.rake - Special tasks for the management of Git operations
# Time-stamp: <Mar 2014-06-10 00:52 svarrette>
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
    git_root_dir = FalkorLib::Git.rootdir #if FalkorLib::Git.init?

    ###########   git:fetch   ###########
    desc "Fetch the latest changes"
    task :fetch do |t|
        info "Fetching latest changes on remotes"
        run %{
           git fetch --all -v
        }
    end # task fetch

    #################   git:push   ##################################
    desc "Push your modifications onto the remote branches"
    task :push => :up do
        info("=> update the remote branches of the Git repository")
        cmd = "git push origin"
        sh %{#{cmd}} do |ok, res|
            if ! ok
                warn("The command '#{cmd}' failed with exit status #{res.exitstatus}")
                warn("This may be due to the fact that you're not connected to the internet")
                really_continue?('no')
            end
        end

    end

    if File.exists?("#{git_root_dir}/.gitmodules")
        #.....................
        namespace :submodules do

            ########### git:submodules:update ###########
            desc "Update the git submodules"
            task :update do |t|
                info "update Git submodules from '#{git_root_dir}'"
                Dir.chdir(git_root_dir) do
                    run %{
                       git submodule init
                       git submodule update
                    }
                end
            end

            ########### git:submodules:upgrade ###########
            desc "Upgrade the git submodules to the latest HEAD commit -- USE WITH CAUTION"
            task :upgrade => [ :update] do |t|
                info "update Git submodules from #{git_root_dir}"
                Dir.chdir(git_root_dir) do
                    run %{
                       git submodule foreach 'git fetch origin; git checkout $(git rev-parse --abbrev-ref HEAD); git reset --hard origin/$(git rev-parse --abbrev-ref HEAD); git submodule update --recursive; git clean -dfx'
                    }
                end

            end
        end # namespace git:submodules
    end

    unless FalkorLib.config.git[:subtrees].empty?
        #.....................
        namespace :subtrees do
            ###########   git:subtrees:init  ###########
            desc "Initialize the Git subtrees defined in FalkorLib.config.git.subtrees"
            task :init do |t|
				FalkorLib::Git.subtrees_init(git_root_dir)
            end # task :init

            ###########   git:subtrees:diff   ###########
            desc "Show difference between local subtree(s) and their remotes"
            task :diff do |t|
                Dir.chdir(git_root_dir) do
                    FalkorLib.config.git[:subtrees].each do |dir,conf|
                        next if conf[:url].nil?
                        url    = conf[:url]
                        remote = dir
                        branch = conf[:branch].nil? ? 'master' : conf[:branch]
                        remotes = FalkorLib::Git.remotes
                        current_branch = FalkorLib::Git.branch?
                        if  remotes.include?( remotes )
                            info "Git diff on subtree '#{dir}' with remote #{remote}/#{branch}"
                            run %{
                               git diff #{remote}/#{branch} #{current_branch}:#{dir}
                            }
                        end

                    end
                end
            end # task :diff


        end # namespace git:subtrees
    end

    ############  git:up   ########################################
    desc "Update your local copy of the repository from GIT server"
    task :up do
        info "Updating your local repository"
        cmd = "git pull origin"
        status = execute( cmd )
        if (status.to_i != 0)
            warn("The command '#{cmd}' failed with exit status #{res.exitstatus}")
            warn("This may be due to the fact that you're not connected to the internet")
            really_continue?('no')
        end
    end

end # namespace git
