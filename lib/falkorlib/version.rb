module FalkorLib
    module Version

        ##
        # Change the MAJOR, MINOR and PATCH constants below
        # to adjust the version of the FalkorLib gem
        #
        # MAJOR:
        #  Defines the major version
        # MINOR:
        #  Defines the minor version
        # PATCH:
        #  Defines the patch version
        MAJOR, MINOR, PATCH = 0, 1, 0

        ##
        # Returns the major version ( big release based off of multiple minor releases )
        def self.major
            MAJOR
        end

        ##
        # Returns the minor version ( small release based off of multiple patches )
        def self.minor
            MINOR
        end

        ##
        # Returns the patch version ( updates, features and (crucial) bug fixes )
        def self.patch
            PATCH
        end

        ##
        # Returns the full version
        def self.to_s
            [ MAJOR, MINOR, PATCH ].join('.')
        end

        ## Return a new version number based on
        # - the old version (format: x.y.z)
        # - the level of bumping (either :major, :minor, :patch)
        def bump_version(oldversion, level)
            if oldversion =~ /^(\d+)\.(\d+)\.(\d+)$/
                major = $1.to_i
                minor = $2.to_i
                patch = $3.to_i
            end
            case level
            when ':major'
                major += 1
                minor = 0
                patch = 0
            when ':minor'
                minor += 1
                patch = 0
            when ':patch'
                patch += 1
            end
            version = [major, minor, patch].compact.join('.')
        end

    end
    VERSION = Version.to_s
end
