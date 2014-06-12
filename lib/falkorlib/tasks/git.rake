# -*- encoding: utf-8 -*-
################################################################################
# git.rake - Special tasks for the management of Git operations
# Time-stamp: <Jeu 2014-06-12 00:14 svarrette>
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
		FalkorLib::Git.fetch()
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

	unless FalkorLib.config.git[:submodules].empty?
		#.....................
		namespace :submodules do
			###########   init   ###########
			desc "Initialize the Git subtrees defined in FalkorLib.config.git.submodules"
			task :init do 
				FalkorLib::Git.submodule_init(git_root_dir)
			end # task submodules:init 


		end # namespace submodules
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
            task :init do 
				FalkorLib::Git.subtree_init(git_root_dir)
            end # task git:subtree:init

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
