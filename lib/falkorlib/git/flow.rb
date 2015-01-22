# -*- encoding: utf-8 -*-
################################################################################
# Time-stamp: <Jeu 2015-01-22 22:51 svarrette>
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

        ## OLD version
        ## Check if git-flow is initialized
        # def init?(path = Dir.pwd)
	    #     res = FalkorLib::Git.init?(path)
	    #     Dir.chdir(path) do 
		#         gf_check = `git config --get-regexp 'gitflow*'`
		#         res &= ! gf_check.empty? 
	    #     end
	    #     res
        # end # init?(path = Dir.pwd)

        ###### init? ######
        # Check if gitflow has been initialized
        ##
        def init?(dir = Dir.pwd)
          res = FalkorLib::Git.init?(dir)
          if res
            res &= !FalkorLib::Git.config('gitflow*', dir).empty?
          end
          res
        end # init?

        ## Initialize a git-flow repository
        # Supported options:
        # :interactive [boolean] confirm Gitflow branch names
        # :master  [string] Branch name for production releases
        # :develop [string] Branch name for development commits
        def init(path = Dir.pwd, options = {})
            exit_status = FalkorLib::Git.init(path, options)
            error "you shall install git-flow: see https://github.com/nvie/gitflow/wiki/Installation" unless command?('git-flow')
            remotes      = FalkorLib::Git.remotes(path)
            git_root_dir = FalkorLib::Git.rootdir( path )
            Dir.chdir( git_root_dir ) do
                unless FalkorLib::Git.has_commits?( git_root_dir)
	                warn "Not yet any commit detected in this repository."
	                readme = 'README.md'
	                unless File.exists?( readme )
		                answer = ask(cyan("=> initialize a commit with an [empty] #{readme} file (Y|n)?"), 'Yes')
		                exit 0 if answer =~ /n.*/i
		                FileUtils.touch(readme)
	                end
	                FalkorLib::Git.add(readme, "Initiate the repository with a '#{readme}' file")
                end
		        branches     = FalkorLib::Git.list_branch(path)
                gitflow_branches = FalkorLib.config.gitflow[:branches].clone
                # correct eventually the considered branch from the options
                gitflow_branches.each do |t,b|
                  gitflow_branches[t] = options[t.to_sym] if options[t.to_sym]
                  confs = FalkorLib::Git.config('gitflow*', path, :hash => true)
                  unless confs.empty?
                    gitflow_branches[t] = confs["gitflow.branch.#{t}"]
                  end
                end
                if options[:interactive]
                  gitflow_branches[:master]  = ask("=> branch name for production releases", gitflow_branches[:master])
                  gitflow_branches[:develop] = ask("=> branch name for development commits", gitflow_branches[:develop])
                end
                ap gitflow_branches if options[:debug]
                if remotes.include?( 'origin' )
                    info "=> configure remote (tracked) branches"
                    exit_status = FalkorLib::Git.fetch(path)
                    gitflow_branches.each do |type,branch|
                        if branches.include? "remotes/origin/#{branch}"
                            exit_status = FalkorLib::Git.grab(branch, path)
                        else
                            unless branches.include? branch
                                info "=> creating the branch '#{branch}'"
                                FalkorLib::Git.create_branch( branch, path )
                            end
                            exit_status = FalkorLib::Git.publish(branch, path )
                        end
                    end
                else
                    gitflow_branches.each do |type, branch|
                        unless branches.include? branch
                            info " => creating the branch '#{branch}'"
                            exit_status = FalkorLib::Git.create_branch( branch, path )
                        end
                    end
                end
                #info "initialize git flow configs"
                gitflow_branches.each do |t,branch|
                    exit_status = execute "git config gitflow.branch.#{t} #{branch}"
                end
                FalkorLib.config.gitflow[:prefix].each do |t,prefix|
                    exit_status = execute "git config gitflow.prefix.#{t} #{prefix}"
                end
		        devel_branch = gitflow_branches[:develop]
		        #info "checkout to the main development branch '#{devel_branch}'"
		        exit_status = run %{ 
                   git checkout #{devel_branch}
                }
		        if branches.include?('master') && ! gitflow_branches.values.include?( 'master' )
			        warn "Your git-flow confuguration does not hold the 'master' branch any more"
			        warn "You probably want to get rid of it asap by running 'git branch -d master'"
		        end 
		        if devel_branch != 'master' && 
				        remotes.include?( 'origin' ) && 
				        branches.include?( 'remotes/origin/master')
			        warn "You might want to change the remote default branch to point to '#{devel_branch}"
			        puts "=> On github: Settings > Default Branch > #{devel_branch}"
			        puts "=> On the remote bare Git repository: 'git symbolic-ref HEAD refs/head/#{devel_branch}'"
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
		        exit_status = run %{ 
                   git flow #{type} #{action} #{optional_args} #{name} 
                }
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

        ###
        # Return the Gitflow branch 
        # :master:   Master Branch name for production releases
        # :develop: 
        ##
        def branches(type = :master, dir = Dir.pwd, options = {})
          FalkorLib::Git.config("gitflow.branch.#{type}", dir)
          #confs[type.to_sym]
        end # master_branch


    end # module FalkorLib::GitFlow

end
