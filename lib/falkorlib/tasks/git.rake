# -*- encoding: utf-8 -*-
################################################################################
# git.rake - Special tasks for the management of Git operations
# Time-stamp: <Jeu 2014-06-12 16:41 svarrette>
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
    desc "Fetch the latest changes on remotes"
    task :fetch do |t|
        info t.comment
		FalkorLib::Git.fetch()
    end # task fetch

    #################   git:push   ##################################
    desc "Push your modifications onto the remote branches"
    task :push => :up do |t|
        info t.full_comment
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
			task :init do |t| 
				info t.full_comment
				FalkorLib::Git.submodule_init(git_root_dir)
			end # task submodules:init 


		end # namespace submodules
	end 

    if File.exists?("#{git_root_dir}/.gitmodules")
        #.....................
        namespace :submodules do

            ########### git:submodules:update ###########
            desc "Update the git submodules from '#{git_root_dir}'"
            task :update do |t|
                info t.comment
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
