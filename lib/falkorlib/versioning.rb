# -*- encoding: utf-8 -*-
################################################################################
# Time-stamp: <Mer 2014-06-18 22:02 svarrette>
################################################################################
# @author Sebastien Varrette <Sebastien.Varrette@uni.lu>
#
# FalkorLib Version management
#

module FalkorLib #:nodoc:

    module Config

        # Default configuration for Versioning Management
        module Versioning
            # Versioning Management defaults
            DEFAULTS = {
                :default => '0.0.1',
                :levels  => [ 'major', 'minor', 'patch' ],
                :type    => 'file',
                :source  => {
                    'file' => {
                        :filename => 'VERSION'
                    },
                    'gem' => {
                        :filename  => 'lib/falkorlib/version.rb',
                        :getmethod => 'FalkorLib::Version.to_s',
                        #:setmethod => 'FalkorLib::Version.set',
                        :pattern   => 'MAJOR\s*,\s*MINOR,\s*PATCH\s*=\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)'
                    },
                    'tag' => {
                        :suffix => 'v'
                    },
                }
            }
        end
    end

    # Semantic Versioning Management
    # @see falkorlib/tasks/versioning.rake
    module Versioning
        module_function

        ## get the current version
        def get_version(rootdir = Dir.pwd)
            version = FalkorLib.config[:versioning][:default]
            type    = FalkorLib.config[:versioning][:type]
            source  = FalkorLib.config[:versioning][:source][ type ]
            case type
            when 'file'
                versionfile = File.join( rootdir, source[:filename] )
                version = File.read( versionfile ).chomp if File.exist? ( versionfile )
            when 'gem'
                getmethod = source[:getmethod ]
                version = eval( getmethod ) unless (getmethod.nil? || getmethod.empty?)
            end
            version
        end

        ## Set the version
        def set_version(version, rootdir = Dir.pwd)
            exit_status = 0
            type    = FalkorLib.config[:versioning][:type]
            source  = FalkorLib.config[:versioning][:source][ type ]
            filelist = FalkorLib::Git.list_files( rootdir )
            tocommit = ""
            case type
            when 'file'
                versionfile = File.join( rootdir, source[:filename] )
                File.open(versionfile, 'w') {|f| f.puts version } if File.exist? ( versionfile )
	            tocommit = source[:filename]
            when 'gem'
                #getmethod = source[:getmethod ]
                #version = eval( getmethod ) unless (getmethod.nil? || getmethod.empty?)
            end
            Dir.chdir( rootdir ) do
		        unless filelist.include?(  tocommit )
			        warning "The version file #{source[:filename]} is not part of the Git repository"
                    answer = ask("Adding the file to the repository? (Y|n)", 'Yes')
	                next if answer =~ /n.*/i
			        exit_status = FalkorLib::Git.add(File.join(rootdir, tocommit), "Adding the version file '#{tocommit}', inialized to the '#{version}' version" )
			        next 
		        end 
		        exit_status = execute "git commit -s -m \"bump to version '#{version}'\" #{tocommit}"
		        #ap exit_status
            end
	        exit_status
        end




        ## Return a new version number based on
        # @param oldversion the old version (format: x.y.z)
        # @param level      the level of bumping (either :major, :minor, :patch)
        def bump(oldversion, level)
            major = minor = patch = 0
            if oldversion =~ /^(\d+)\.(\d+)\.(\d+)$/
                major = $1.to_i
                minor = $2.to_i
                patch = $3.to_i
            end
            case level.to_sym
            when :major
                major += 1
                minor = 0
                patch = 0
            when :minor
                minor += 1
                patch = 0
            when :patch
                patch += 1
            end
            version = [major, minor, patch].compact.join('.')
        end
    end

end
