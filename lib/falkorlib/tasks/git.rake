# -*- encoding: utf-8 -*-
################################################################################
# git.rake - Special tasks for the management of Git operations
# Time-stamp: <Jeu 2014-06-05 22:58 svarrette>
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

    ############  git:up   ########################################
    desc "Update your local copy of the repository from GIT server"
    task :up do
        info "Updating your local repository"
        cmd = "git pull origin"
        sh %{#{cmd}} do |ok, res|
            if ! ok
                warn("The command '#{cmd}' failed with exit status #{res.exitstatus}")
                warn("This may be due to the fact that you're not connected to the internet")
                really_continue?('no')
            end
        end
    end

end # namespace git
