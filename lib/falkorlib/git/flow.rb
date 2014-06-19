# -*- encoding: utf-8 -*-
################################################################################
# Time-stamp: <Jeu 2014-06-19 18:02 svarrette>
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
            remotes      = FalkorLib::Git.remotes(path)
            git_root_dir = FalkorLib::Git.rootdir( path )
            Dir.chdir( git_root_dir ) do
                unless FalkorLib::Git.has_commits?( git_root_dir)
	                warn "Not yet any commit detected in this repository."
	                readme = 'README.md'
	                answer = ask(cyan("=> Shall one be initiated with a #{readme} file (Y|n)?"), 'Yes')
	                exit 0 if answer =~ /n.*/i
	                FileUtils.touch(readme)
	                FalkorLib::Git.add(readme, "Initiate the repository with a '#{readme}' file")
                end
		        branches     = FalkorLib::Git.list_branch(path)
                if remotes.include?( 'origin' )
                    info "=> configure remote (tracked) branches"
                    exit_status = FalkorLib::Git.fetch(path)
                    FalkorLib.config.gitflow[:branches].each do |type,branch|
                        if branches.include? "remotes/origin/#{branch}"
                            exit_status = FalkorLib::Git.grab(branch, path)
                        else
                            unless branches.include? branch
                                info "Creating the branch '#{branch}'"
                                FalkorLib::Git.create_branch( branch, path )
                            end
                            exit_status = FalkorLib::Git.publish(branch, path )
                        end
                    end
                else
                    FalkorLib.config.gitflow[:branches].each do |type, branch|
                        unless branches.include? branch
                            info "creating the branch '#{branch}'"
                            exit_status = FalkorLib::Git.create_branch( branch, path )
                        end
                    end
                end
                info "Initialize git flow configs"
                FalkorLib.config.gitflow[:branches].each do |t,branch|
                    exit_status = execute "git config gitflow.branch.#{t} #{branch}"
                end
                FalkorLib.config.gitflow[:prefix].each do |t,prefix|
                    exit_status = execute "git config gitflow.prefix.#{t} #{prefix}"
                end
            end
	        exit_status
        end


        ## generic function to run any of the gitflow commands
        def command(name, type = 'feature', action = 'start', path = Dir.pwd, optional_args = '')
            error "Invalid git-flow type '#{type}'" unless ['feature', 'release', 'hotfix', 'support'].include?(type)
            error "Invalid action '#{action}'" unless ['start', 'finish'].include?(action)
            error "You must provide a name" if name == ''
            error "The name '#{name}' cannot contain spaces" if name =~ /\s+/
            exit_status = 1
            Dir.chdir( FalkorLib::Git.rootdir(path) ) do
		        cmd = "git flow #{type} #{action} #{optional_args} #{name}"
		        puts bold("[Running] #{cmd}")
		        system(cmd)
		        exit_status = $?
		        #exit_status = `#{cmd}`.to_i
            end
            exit_status
        end

        ## git flow {feature, hotfix, release, support} start <name>
        def start (type, name, path = Dir.pwd, optional_args = '')
            command(name, type, 'start', path, optional_args)
        end

        ## git flow {feature, hotfix, release, support} finish <name>
        def finish (type, name, path = Dir.pwd, optional_args = '')
            command(name, type, 'finish', path, optional_args)
        end


    end # module FalkorLib::GitFlow

end
