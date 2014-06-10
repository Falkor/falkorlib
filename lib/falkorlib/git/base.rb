# -*- encoding: utf-8 -*-
################################################################################
# Time-stamp: <Mar 2014-06-10 23:37 svarrette>
################################################################################
# Interface for the main Git operations
#
# On purpose, I try to avoid using the Git library to avoid instanciate the Git
# class and thus managing the working directory

require "falkorlib"
require "falkorlib/common"

require "minigit"
require "pathname"

include FalkorLib::Common

module FalkorLib  #:nodoc:
    module Config

        # Default configuration for Git
        module Git
            # Git defaults for FalkorLib
            DEFAULTS = {
                :submodulesdir => '.submodules',
                :submodules => {},
                :subtrees   => {}
            }
        end
    end

    # Management of Git operations
    module Git
        module_function

        ## Check if a git directory has been initialized
        def init?(path = Dir.pwd)
            begin
                g = MiniGit.new(path)
            rescue Exception
                return false
            end
            return true
        end

        ## Check the availability of a given git command
        def command?(cmd, path = Dir.pwd)
            cg = MiniGit::Capturing.new(path)
            cmd_list = cg.help :a => true
            # typical run:
            # usage: git [--version] [--help] [-C <path>] [-c name=value]
            #            [--exec-path[=<path>]] [--html-path] [--man-path] [--info-path]
            #            [-p|--paginate|--no-pager] [--no-replace-objects] [--bare]
            #            [--git-dir=<path>] [--work-tree=<path>] [--namespace=<name>]
            #            <command> [<args>]
            #
            # available git commands in '/usr/local/Cellar/git/1.8.5.2/libexec/git-core'
            #
            #   add   [...]   \
            #   [...]          | The part we are interested in, delimited by '\n\n' sequence
            #   [...]         /
            #
            # 'git help -a' and 'git help -g' lists available subcommands and some
            # concept guides. See 'git help <command>' or 'git help <concept>'
            # to read about a specific subcommand or concept
            l = cmd_list.split("\n\n")
	        l.shift # useless first part
	        #ap l
	        subl = l.each_index.select{|i| l[i] =~ /^\s\s+/ } # find sublines that starts with at least two whitespaces
	        #ap subl
	        return false if subl.empty?
	        subl.any? { |i| l[i].split.include?(cmd) }
        end

        ## Initialize a git repository
        def init(path = Dir.pwd)
            # FIXME for travis test: ensure the global git configurations
            # 'user.email' and 'user.name' are set
            [ 'user.name', 'user.email' ].each do |userconf|
                if MiniGit[userconf].nil?
                    warn "The Git global configuration '#{userconf}' is not set so"
                    warn "you should *seriously* consider setting them by running\n\t git config --global #{userconf} 'your_#{userconf.sub(/\./, '_')}'"
                    default_val = ENV['USER']
                    default_val += '@domain.org' if userconf =~ /email/
                    warn "Now putting a default value '#{default_val}' you could change later on"
                    run %{
                         git config --global #{userconf} "#{default_val}"
                    }
                    #MiniGit[userconf] = default_val
                end
            end
            #puts "#init #{path}"
            Dir.chdir( "#{path}" ) do
                %x[ pwd && git init ] unless FalkorLib.config.debug
            end
        end

        # Return the Git working tree from the proposed path (current directory by default)
        def rootdir(path = Dir.pwd)
            g = MiniGit.new
            g.find_git_dir(path)[1]
        end

        # Return the git root directory for the path (current directory by default)
        def gitdir(path = Dir.pwd)
            g = MiniGit.new
            g.find_git_dir(path)[0]
        end

        # Create a new branch
        def create_branch(branch, path = Dir.pwd)
            g = MiniGit.new(path)
            g.branch "#{branch}"
        end

        ## Fetch the latest changes
        def fetch(path = Dir.pwd)
	        Dir.chdir( path ) do 
		        execute "git fetch --all -v"
	        end
        end

        ## Get an array of the local branches present (first element is always the
        ## current branch)
        def list_branch(path = Dir.pwd)
            cg = MiniGit::Capturing.new(path)
            res = cg.branch.split("\n")
            # Eventually reorder to make the first element of the array the current branch
            i = res.find_index { |e| e =~ /^\*\s/ }
            unless (i.nil? || i == 0)
                res[0], res[i] = res[i], res[0]
            end
            res.each { |e| e.sub!(/^\*?\s+/, '')  }
            res
        end

        ## Get the current git branch
        def branch?(path = Dir.pwd)
            list_branch(path)[0]
        end

        ## Add a file/whatever to Git and commit it
        def add(path, msg = "")
            dir  = File.realpath File.dirname(path)
            root = rootdir(path)
            relative_path_to_root = Pathname.new( File.realpath(path) ).relative_path_from Pathname.new(root)
            real_msg = (msg.empty? ? "add '#{relative_path_to_root}'" : msg)
            Dir.chdir( dir ) do
                run %{
                  git add #{path}
                  git commit -s -m "#{real_msg}" #{path}
                }
            end
        end

        ## Check if a git directory is in dirty mode
        # git diff --shortstat 2> /dev/null | tail -n1
        def dirty?(path = Dir.pwd)
            g = MiniGit.new(path)
            a = g.capturing.diff :shortstat => true
            #ap a
            ! a.empty?
        end

        ## List of Git remotes
        def remotes(path = Dir.pwd)
            g = MiniGit.new(path)
            g.capturing.remote.split()
        end

        ## Initialize git subtrees from the configuration
        def subtree_init(path = Dir.pwd)
            raise ArgumentError, "Git 'subtree' command is not available" unless FalkorLib::Git.command? "subtree"
            if FalkorLib.config.git[:subtrees].empty?
                FalkorLib::Git.subtrees_warn
                return 1
            end
	        exit_status = 0
            git_root_dir = rootdir(path)
            Dir.chdir(git_root_dir) do
                FalkorLib.config.git[:subtrees].each do |dir,conf|
                    next if conf[:url].nil?
                    url    = conf[:url]
                    remote = dir
                    branch = conf[:branch].nil? ? 'master' : conf[:branch]
                    remotes = FalkorLib::Git.remotes
                    unless remotes.include?( remote )
                        info "Initialize Git remote '#{remote}' from URL '#{url}'"
	                    exit_status = execute "git remote add -f #{dir} #{url}"
                    end
                    unless File.directory?( File.join(git_root_dir, dir) )
                        info "initialize Git subtree '#{dir}'"
                        exit_status = execute "git subtree add --prefix #{dir} --squash #{remote}/#{branch}"
                    end
                end

            end
            exit_status
        end

        ## Show difference between local subtree(s) and their remotes"
        def subtree_diff(path = Dir.pwd)
	        raise ArgumentError, "Git 'subtree' command is not available" unless FalkorLib::Git.command? "subtree"
            if FalkorLib.config.git[:subtrees].empty?
                FalkorLib::Git.subtrees_warn
                return 1
            end
	        exit_status = 0
	        git_root_dir = rootdir(path)
	        Dir.chdir(git_root_dir) do
		        FalkorLib.config.git[:subtrees].each do |dir,conf|
			        next if conf[:url].nil?
			        url    = conf[:url]
			        remote = dir
			        branch = conf[:branch].nil? ? 'master' : conf[:branch]
			        remotes = FalkorLib::Git.remotes
			        raise IOError, "The git remote '#{remote}' is not configured" unless remotes.include?( remote )
			        raise IOError, "The git subtree directory '#{dir}' does not exists" unless File.directory? ( File.join(git_root_dir, dir) )
			        info "Git diff on subtree '#{dir}' with remote '#{remote}/#{branch}'"
			        exit_status = execute "git diff #{remote}/#{branch} #{FalkorLib::Git.branch?( git_root_dir )}:#{dir}"
		        end
	        end
	        exit_status
        end

        # Pull the latest changes, assuming the git repository is not dirty
        def subtree_up(path = Dir.pwd)
	        error "Unable to pull subtree(s): Dirty Git repository" if FalkorLib::Git.dirty?
	        exit_status = 0
	        git_root_dir = rootdir(path)
	        Dir.chdir(git_root_dir) do
		        FalkorLib.config.git[:subtrees].each do |dir,conf|
			        next if conf[:url].nil?
			        url    = conf[:url]
			        remote = dir
			        branch = conf[:branch].nil? ? 'master' : conf[:branch]
			        remotes = FalkorLib::Git.remotes
			        info "Pulling changes into subtree '#{dir}' using remote '#{remote}/#{branch}'"
			        raise IOError, "The git remote '#{remote}' is not configured" unless remotes.include?( remote )
			        info "\t\\__ fetching remote '#{remotes.join(',')}'"
			        FalkorLib::Git.fetch( git_root_dir )
			        raise IOError, "The git subtree directory '#{dir}' does not exists" unless File.directory? ( File.join(git_root_dir, dir) )
			        info "\t\\__ pulling changes"
			        exit_status = execute "git subtree pull --prefix #{dir} --squash #{remote} #{branch}"
		        end
	        end
	        exit_status

        end
        alias :subtree_pull :subtree_up 


        # Raise a warning message if s
        def subtrees_warn
            warn "You shall setup 'FalkorLib.config.git[:subtrees]' to configure subtrees as follows:"
            warn "     FalkorLib.config.git do |c|"
            warn "       c[:subtrees] = {"
            warn "          '<subdir>' => {"
            warn "             :url    => '<giturl>',"
            warn "             :branch => 'develop'   # if different from master"
            warn "          },"
            warn "        }"
            warn "     end"
        end
    end # module FalkorLib::Git
end # module FalkorLib
