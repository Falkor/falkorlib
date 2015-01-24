# -*- encoding: utf-8 -*-
################################################################################
# Time-stamp: <Sam 2015-01-24 11:12 svarrette>
################################################################################
# @author Sebastien Varrette <Sebastien.Varrette@uni.lu>
#
# FalkorLib Version management
#
require 'json'

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
                        #:pattern   => '^(\s*)MAJOR\s*,\s*MINOR,\s*PATCH\s*=\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)'
                    },
			        'puppet_module' => {
				        :filename => 'metadata.json'
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

        ######
        # Get the current version
        # Supported options:
        # * :default [string] default version
        # * :type    in ['file','gem','puppet_module'] type of versionning mechanism
        # * :source  [Hash] information on the way to retrieve the information
        def get_version(rootdir = Dir.pwd, options = {})
            version = options[:default] ? options[:default] : FalkorLib.config[:versioning][:default]
            type    = options[:type]    ? options[:type]    : FalkorLib.config[:versioning][:type]
            source  = options[:source]  ? options[:source]  : FalkorLib.config[:versioning][:source][ type ]
	        case type
            when 'file'
                versionfile = File.join( rootdir, source[:filename] )
                version = File.read( versionfile ).chomp if File.exist? ( versionfile )
            when 'gem'
                getmethod = source[:getmethod ]
                version = eval( getmethod ) unless (getmethod.nil? || getmethod.empty?)
            when 'puppet_module'
	            jsonfile = File.join( rootdir, source[:filename] )
	            metadata = JSON.parse( IO.read( jsonfile ) )
	            version  = metadata["version"]
            end
            version
        end

        ######
        # Set the version
        # Supported options:
        # * :type    in ['file','gem','puppet_module'] type of versionning mechanism
        # * :source  [Hash] information on the way to retrieve the information
        def set_version(version, rootdir = Dir.pwd, options = {})
            exit_status = 0
            type    = options[:type]    ? options[:type]    : FalkorLib.config[:versioning][:type]
            source  = options[:source]  ? options[:source]  : FalkorLib.config[:versioning][:source][ type ]
	        versionfile = File.join( rootdir, source[:filename] ) unless source[:filename].nil?
            filelist = FalkorLib::Git.list_files( rootdir )
            major, minor, patch =  major(version), minor(version), patch(version)
            #tocommit = ""
            case type
            when 'file'
	            info "writing version changes in #{source[:filename]}"
	            File.open(versionfile, 'w') {|f| f.puts version } if File.exist? ( versionfile )
            when 'gem'
	            info "=> writing version changes in #{source[:filename]}"
	            File.open(versionfile, 'r+') do |f|
                    text = f.read
			        text.gsub!(/^(\s*)MAJOR\s*,\s*MINOR,\s*PATCH\s*=\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)(.*)$/, 
			                   '\1' + "MAJOR, MINOR, PATCH = #{major}, #{minor}, #{patch}" + '\5')
                    f.rewind
                    f.write(text)
                end
            when 'puppet_module'
	            info "=> writing version changes in #{source[:filename]}"
	            metadata = JSON.parse( IO.read( versionfile ) )
	            metadata["version"] = version
	            File.open(versionfile,"w") do |f|
			        f.write JSON.pretty_generate( metadata )
                end
	            #exit 1
            end
            Dir.chdir( rootdir ) do
                next if source[:filename].nil?
                unless filelist.include?(  source[:filename] )
                    warning "The version file #{source[:filename]} is not part of the Git repository"
                    answer = ask("Adding the file to the repository? (Y|n)", 'Yes')
                    next if answer =~ /n.*/i
                    exit_status = FalkorLib::Git.add(versionfile, "Adding the version file '#{source[:filename]}', inialized to the '#{version}' version" )
                    next
                end
		        run %{ 
                   git diff #{source[:filename]} 
                }
		        answer = ask(cyan("=> Commit the changes of the version file to the repository? (Y|n)"), 'Yes')
		        next if answer =~ /n.*/i
		        run %{ 
                   git commit -s -m "bump to version '#{version}'" #{source[:filename]} 
                }
		        exit_status = $?.to_i
		        # if (type == 'gem' && File.exists?(File.join(rootdir, 'Gemfile')) )
			    #     run %{
                #        sleep 2 
                #        bundle update falkorlib
                #        git commit -s -m "Update Gemfile.lock accordingly" Gemfile.lock
                #     } if command?( 'bundle' )
		        # end 
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

        # for rspec
        module Gem
        end
        # for rspec
        module Puppet
        end

    end # module

end
