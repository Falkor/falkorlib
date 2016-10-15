# -*- encoding: utf-8 -*-
################################################################################
# Time-stamp: <Mon 2016-06-27 10:41 svarrette>
################################################################################
# @author Sebastien Varrette <Sebastien.Varrette@uni.lu>
#
# SysAdmin Warrior (SAW) Version management
#

module SysAdminWarrior #:nodoc:

  # Management of the current version of the library
  module Version

    # Change the MAJOR, MINOR and PATCH constants below
    # to adjust the version of the FalkorLib gem
    #
    # MAJOR: Defines the major version
    # MINOR: Defines the minor version
    # PATCH: Defines the patch version
    MAJOR, MINOR, PATCH = 0, 0, 1

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

  end

  # Shorter version of the Gem's VERSION
  VERSION = Version.to_s
end
