# -*- encoding: utf-8 -*-
# Time-stamp: <Mer 2014-06-04 22:54 svarrette>
#
# Interface for the main Git operations
################################################################################
# On purpose, I try to avoid using the Git library to avoid instanciate the Git
# class and thus managing the working directory

require "falkorlib"
require "falkorlib/common"

#require "git"
require "minigit"

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
	        puts "#init #{path}"
	        Dir.chdir( "#{path}" ) do
		       %x[ pwd && git init ] unless FalkorLib.config.debug
		       #run %{ git init } # unless FalkorLib.debug
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


        ## Get an array of the local branches present (first element is always the
        ## current branch)
        def get_branches()
            res = MiniGit::Capturing.branch.split("\n")
            # Eventually reorder to make the first element of the array the current branch
            i = res.find_index { |e| e =~ /^\*\s/ }
            unless (i.nil? || i == 0)
                res[0], res[i] = res[i], res[0]
            end
            res.each { |e| e.sub!(/^\*?\s+/, '')  }
            res
        end

        ## Get the current git branch
        def branch?()
            get_branches[0]
        end

        ## Add a file and commit
        def add(path, msg = "")
            dir = File.dirname(path)
            run %{echo #{dir}}
        end



    end # module FalkorLib::Git
end # module FalkorLib
