# -*- encoding: utf-8 -*-
# Time-stamp: <Jeu 2014-06-05 14:01 svarrette>
#
# Interface for the main Git operations
################################################################################
# On purpose, I try to avoid using the Git library to avoid instanciate the Git
# class and thus managing the working directory

require "falkorlib"
require "falkorlib/common"

#require "git"
require "minigit"
require "pathname"

include FalkorLib::Common

module FalkorLib

    # class  Git
    #   def initialize
    #       @branches = ::Minigit::Capturing.branch.split("\n")
    #   end

    # end

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


    end # module FalkorLib::Git
end # module FalkorLib
