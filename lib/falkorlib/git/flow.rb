# -*- encoding: utf-8 -*-
################################################################################
# Time-stamp: <Ven 2014-06-13 11:01 svarrette>
################################################################################
# Management of Git Flow operations

require "falkorlib"
require "falkorlib/common"
require "falkorlib/git/base"

include FalkorLib::Common

module FalkorLib
    module Config

        # Default configuration for Gitflow
        module GitFlow
            # git flow defaults
            DEFAULTS = {
                :branches => {
                    :master     => 'production',
                    :develop    => 'master',
                },
                :prefix => {
                    :feature    => 'feature/',
                    :release    => 'release/',
                    :hotfix     => 'hotfix/',
                    :support    => 'support/',
                    :versiontag => "v",
                }
            }
        end
    end


    # Management of [git flow](https://github.com/nvie/gitflow) operations I'm
    # using everywhere
    module GitFlow

        module_function

        ## Initialize a git-flow repository
        def init(path = Dir.pwd)
            exit_status = FalkorLib::Git.init(path)
            error "you shall install git-flow: see https://github.com/nvie/gitflow/wiki/Installation" unless command?('git-flow')
            remotes = FalkorLib::Git.remotes(path)
            branches = FalkorLib::Git.list_branch(path)
            if remotes.include?( 'origin' )
                info "=> configure remote (tracked) branches"
                exit_status = FalkorLib::Git.fetch(path)
                FalkorLib.config.gitflow[:branches].each do |type,branch|
                    if branches.include? "remotes/origin/#{branch}"
                        exit_status = FalkorLib::Git.grab(branch, path)
                    else
                        unless branches.include? branch
                            info "creating the branch '#{branch}'"
                            FalkorLib::Git.create_branch( branch, path )
                        end
                        exit_status = FalkorLib::Git.publish(branch, path )
                    end
                end
            else
                FalkorLib.config.gitflow[:branches].each do |type, branch|
                    unless branches.include? branch
                        info "creating the branch '#{branch}'"
                        FalkorLib::Git.create_branch( branch, path )
                    end
                end
            end 
            info "Initialize git flow configs"
	        FalkorLib.config.gitflow[:branches].each do |t,branch|
		        execute "git config gitflow.branch.#{t} #{branch}"
	        end 
            FalkorLib.config.gitflow[:prefix].each do |t,prefix|
                execute "git config gitflow.prefix.#{t} #{prefix}"
            end
        end

        
    end # module FalkorLib::GitFlow

end
