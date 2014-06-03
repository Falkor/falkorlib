# -*- encoding: utf-8 -*-
# Time-stamp: <Mar 2014-06-03 23:48 svarrette>
#
# Interface for the main Git operations
################################################################################
# On purpose, I try to avoid using the Git library to avoid instanciate the Git
# class and thus managing the working directory  

require "falkorlib"
require "falkorlib/common"
require "git"

include FalkorLib::Common

module FalkorLib
    class Git << ::Git::Base
	    
	    ## Get the current git branch
	    def git_branch?()
		    run %{echo roro}
		    (`git branch --no-color 2>/dev/null  | grep -e "^*" | sed -e "s/^\* //"`).chomp
	    end

	    ## Get an array of the local branches present (first element is always the
	    ## current branch)
	    def get_git_branches()
		    res = (`git branch --no-color | sort -r`).split
		    res.delete("*")
		    res
	    end




    end # module FalkorLib::Git 
end # module FalkorLib
