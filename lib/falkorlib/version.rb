# -*- encoding: utf-8 -*-
################################################################################
# Time-stamp: <Mer 2014-06-18 17:45 svarrette>
################################################################################
# @author Sebastien Varrette <Sebastien.Varrette@uni.lu>
#
# FalkorLib Version management
#

module FalkorLib #:nodoc:

    # Management of the current version of the library
    # @see falkorlib/tasks/versioning.rake
    module Version

        # Change the MAJOR, MINOR and PATCH constants below
        # to adjust the version of the FalkorLib gem
        #
        # MAJOR: Defines the major version
        # MINOR: Defines the minor version
        # PATCH: Defines the patch version
	    MAJOR, MINOR, PATCH = 0, 2, 1  
	    
	    module_function
	    
	    ## Returns the major version ( big release based off of multiple minor releases )
	    def major
		    MAJOR
	    end
	    
	    ## Returns the minor version ( small release based off of multiple patches )
	    def minor
		    MINOR		    
	    end

        ## Returns the patch version ( updates, features and (crucial) bug fixes )
	    def patch
		    PATCH
	    end

        ## @return the full version string
	    def to_s
		    [ MAJOR, MINOR, PATCH ].join('.')
	    end

        # ## Return a new version number based on
        # # @param oldversion the old version (format: x.y.z)
        # # @param level      the level of bumping (either :major, :minor, :patch)
	    # def bump_version(oldversion, level)
        #     major = minor = patch = 0
        #     if oldversion =~ /^(\d+)\.(\d+)\.(\d+)$/
        #         major = $1.to_i
        #         minor = $2.to_i
        #         patch = $3.to_i
        #     end
        #     case level
        #     when ':major'
        #         major += 1
        #         minor = 0
        #         patch = 0
        #     when ':minor'
        #         minor += 1
        #         patch = 0
        #     when ':patch'
        #         patch += 1
        #     end
        #     version = [major, minor, patch].compact.join('.')
        # end
    end

    # Shorter version of the Gem's VERSION
    VERSION = Version.to_s
end
