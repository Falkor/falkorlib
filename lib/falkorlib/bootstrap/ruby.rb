# -*- encoding: utf-8 -*-
################################################################################
# Time-stamp: <Sun 2018-11-11 18:03 svarrette>
################################################################################
# Interface for the bootstrapping RVM/ruby operations
#

require "falkorlib"
require "falkorlib/common"
require "falkorlib/bootstrap"

require 'erb' # required for module generation
require 'artii'
require 'facter'

include FalkorLib::Common



module FalkorLib
  module Bootstrap #:nodoc:

    module_function

    ###### rvm ######
    # Initialize RVM in the current directory
    # Supported options:
    #  * :force       [boolean] force overwritting
    #  * :ruby        [string]  Ruby version to configure for RVM
    #  * :versionfile [string]  Ruby Version file
    #  * :gemset      [string]  RVM Gemset to configure
    #  * :gemsetfile  [string]  RVM Gemset file
    #  * :commit      [boolean] Commit the changes NOT YET USED
    ##
    def rvm(dir = Dir.pwd, options = {})
      info "Initialize Ruby Version Manager (RVM)"
      ap options if options[:debug]
      path = normalized_path(dir)
      use_git = FalkorLib::Git.init?(path)
      rootdir = (use_git) ? FalkorLib::Git.rootdir(path) : path
      files = {}
      exit_status = 1
      [:versionfile, :gemsetfile].each do |type|
        f = (options[type.to_sym].nil?) ? FalkorLib.config[:rvm][type.to_sym] : options[type.to_sym]
        if File.exist?( File.join( rootdir, f ))
          content = `cat #{File.join( rootdir, f)}`.chomp
          warning "The RVM file '#{f}' already exists (and contains '#{content}')"
          next unless options[:force]
          warning "... and it WILL BE overwritten"
        end
        files[type.to_sym] = f
      end
      # ==== Ruby version ===
      unless files[:versionfile].nil?
        file = File.join(rootdir, files[:versionfile])
        v = FalkorLib.config[:rvm][:version]
        if options[:ruby]
          v = options[:ruby]
        else
          select_from(FalkorLib.config[:rvm][:rubies],
                      "Select RVM ruby to configure for this directory",
                      (FalkorLib.config[:rvm][:rubies].find_index(FalkorLib.config[:rvm][:version]) + 1))
        end
        info " ==>  configuring RVM version file '#{files[:versionfile]}' for ruby version '#{v}'"
        File.open(file, 'w') do |f|
          f.puts v
        end
        exit_status = (File.exist?(file) && (`cat #{file}`.chomp == v)) ? 0 : 1
        FalkorLib::Git.add(File.join(rootdir, files[:versionfile])) if use_git
      end
      # === Gemset ===
      if files[:gemsetfile]
        file = File.join(rootdir, files[:gemsetfile])
        default_gemset = File.basename(rootdir)
        default_gemset = `cat #{file}`.chomp if File.exist?( file )
        g = (options[:gemset]) ? options[:gemset] : ask("Enter RVM gemset name for this directory", default_gemset)
        info " ==>  configuring RVM gemset file '#{files[:gemsetfile]}' with content '#{g}'"
        File.open( File.join(rootdir, files[:gemsetfile]), 'w') do |f|
          f.puts g
        end
        exit_status = (File.exist?(file) && (`cat #{file}`.chomp == g)) ? 0 : 1
        FalkorLib::Git.add(File.join(rootdir, files[:gemsetfile])) if use_git
      end
      # ==== Gemfile ===
      gemfile = File.join(rootdir, 'Gemfile')
      unless File.exist?( gemfile )
        # Dir.chdir(rootdir) do
        #     run %{ bundle init }
        # end
        info " ==>  configuring Gemfile with Falkorlib"
        File.open( gemfile, 'a') do |f|
          f.puts "source 'https://rubygems.org'"
          f.puts ""
          f.puts "gem 'falkorlib' #, :path => '~/git/github.com/Falkor/falkorlib'"
        end
        FalkorLib::Git.add(gemfile) if use_git
      end
      exit_status.to_i
    end # rvm

  end # module Bootstrap
end # module FalkorLib
