# -*- encoding: utf-8 -*-
################################################################################
# Time-stamp: <Jeu 2014-06-19 00:08 svarrette>
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
                        :pattern   => '^(\s*)MAJOR\s*,\s*MINOR,\s*PATCH\s*=\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)'
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

        ## extract the major part of the version
        def major(version)
            res = 0
            res = $1 if version =~ /^\s*(\d+)\.\d+\.\d+/
            res
        end

        ## extract the minor part of the version
        def minor(version)
            res = 0
            res = $1 if version =~ /^\s*\d+\.(\d+)\.\d+/
            res
        end

        ## extract the patch part of the version
        def patch(version)
            res = 0
            res = $1 if version =~ /^\s*\d+\.\d+\.(\d+)/
            res
        end


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
            major, minor, patch =  major(version), minor(version), patch(version)
            tocommit = ""
            case type
            when 'file'
                versionfile = File.join( rootdir, source[:filename] )
                File.open(versionfile, 'w') {|f| f.puts version } if File.exist? ( versionfile )
                tocommit = source[:filename]
            when 'gem'
                puts "gem mode - " + major + minor + patch
                versionfile =  File.join( rootdir, source[:filename] )
                File.open(versionfile, "rw") do |f|
                    text = f.read
			        text.gsub!(/^(\s*)MAJOR\s*,\s*MINOR,\s*PATCH\s*=\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)/, 
			                   $1 + "MAJOR, MINOR, PATCH = #{major}, #{minor}, #{patch}")
                    f.rewind
                    f.write(text)
                end


                # File.open(versionfile + '.new', 'w') do |out|
                #     File.open(versionfile, 'r').each do |line|
                #         newline = line.gsub(/^(\s*)MAJOR\s*,\s*MINOR,\s*PATCH\s*=\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)/) do |m|
                #             newline = $1 + "MAJOR, MINOR, PATCH = #{major}, #{minor}, #{patch}"
                #         end
                #         out.print newline
                #     end
                # end


                exit 1
                #getmethod = source[:getmethod ]
                #version = eval( getmethod ) unless (getmethod.nil? || getmethod.empty?)
            end
            Dir.chdir( rootdir ) do
                next if tocommit.empty?
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
