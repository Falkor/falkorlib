################################################################################
# gitflow.rake - Special tasks for the management of Git [Flow] operations
# Time-stamp: <Ven 2014-06-13 12:02 svarrette>
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

    #.....................
    namespace :flow do

        ###########   git:flow:init   ###########
        desc "Initialize your local clone of the repository for the git-flow management"
        task :init do |t|
            FalkorLib::GitFlow.init(git_root_dir)
        end # task init

    end # namespace git::flow


    ['feature', 'hotfix', 'support'].each do |op|
        #.....................
        namespace op.to_sym do

            #########   git:{feature,hotfix,support}:start ##########################
            desc "Start a new #{op} operation on the repository using the git-flow framework"
            task :start do |t|
                name = ask("Name of the #{op} (the git branch will be 'feature/<name>')")
                info t.comment
                really_continue?
                Rake::Task['git:up'].invoke unless FalkorLib::Git.remotes.empty?
                info "=> prepare new '#{op}' using git flow"
                FalkorLib::GitFlow.start(op, name)
                # Now you should be in the new branch
            end

            #########   git:{feature,hotfix,support}:finish ##########################
            desc "Finalize the #{op} operation"
            task :finish do |t|
                branch = FalkorLib::Git.branch?
                expected_branch_prefix = FalkorLib.config.gitflow[:prefix][op.to_sym]
                if branch !~ /^#{expected_branch_prefix}/
                    error "You are not in the expected branch (with prefix '#{expected_branch_prefix}')"
                end
                name = branch.sub(/^#{expected_branch_prefix}/, '')
                info t.comment
                FalkorLib::GitFlow.finish(op, name)
                unless FalkorLib::Git.remotes.empty?
                    info "=> about to update remote tracked branches"
                    really_continue?
                    Rake::Task['git:push'].invoke
                end
            end
        end # End namespace 'git:{feature,hotfix,support}'
    end




end # namespace git
