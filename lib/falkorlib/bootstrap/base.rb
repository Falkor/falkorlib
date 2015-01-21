# -*- encoding: utf-8 -*-
################################################################################
# Time-stamp: <Mer 2015-01-21 21:50 svarrette>
################################################################################
# Interface for the main Bootstrapping operations
#

require "falkorlib"
require "falkorlib/common"

include FalkorLib::Common

module FalkorLib  #:nodoc:
  module Config

    # Default configuration for Bootstrapping processes
    module Bootstrap
      DEFAULTS =
        {
         :trashdir => '.Trash',
         :types    => [ 'article', 'slides', 'gem', 'octopress', 'puppet_module', 'rvm' ],
         :rvm => {
                  :version     => '1.9.3',
                  :versionfile => '.ruby-version',
                  :gemsetfile  => '.ruby-gemset'
                 },
         :puppet   => {},
        }


    end
  end
end



module FalkorLib
  module Bootstrap
    module_function

    ###
    # Initialize a trash directory in path
    ##
    def trash(path = Dir.pwd, dirname = FalkorLib.config[:templates][:trashdir], options = {})
      #args = method(__method__).parameters.map { |arg| arg[1].to_s }.map { |arg| { arg.to_sym => eval(arg) } }.reduce Hash.new, :merge
      #ap args
      if Dir.exists?(dirname)
        warning "The trash directory '#{dirname}' already exists"
        return
      end
      Dir.chdir(path) do
        info "creating the trash directory '#{dirname}'"
        run %{
          mkdir #{dirname}
          echo '*' > #{dirname}/.gitignore
        }
        if FalkorLib::Git.init?(path)
          FalkorLib::Git.add(File.join(path, dirname, '.gitignore' ), 'Add Trash directory',
                             { :force => true } )
        end
      end
    end # trash

    ###### rvm ######
    # Initialize RVM in the current directory
    # Supported options:
    #  * :force       [boolean] force overwritting
    #  * :ruby        [string]  Ruby version to configure for RVM
    #  * :versionfile [string]  Ruby Version file
    #  * :gemset      [string]  RVM Gemset to configure
    #  * :gemsetfile  [string]  RVM Gemset file
    ##
    def rvm(dir = Dir.pwd, options = {})
      info "Initialize RVM"
      ap options if options[:debug]
      files = {}
      rootdir = FalkorLib::Git.init?(dir) ? FalkorLib::Git.rootdir(dir) : dir
      [:versionfile, :gemsetfile].each do |type|
        f = options[type.to_sym].nil? ? FalkorLib.config[:rvm][type.to_sym] : options[type.to_sym]
        if File.exists?( File.join( rootdir, f ))
          content = `cat #{File.join( rootdir, f)}`.chomp
          warning "The RVM file '#{f}' already exists (and contains '#{content}')"
          next unless options[:force]
          warning "... and it WILL BE overwritten"
        end
        files[type.to_sym] = f
      end
      # ==== Ruby version ===
      unless files[:versionfile].nil?
        v =
          options[:ruby] ?
          options[:ruby] :
          select_from(FalkorLib.config[:rvm][:rubies],
                      "Select RVM ruby to configure for this directory",
                      1)
        info " ==>  configuring RVM version file '#{files[:versionfile]}' for ruby version '#{v}'"
        File.open( File.join(rootdir, files[:versionfile]), 'w') do |f|
          f.puts v
        end
        FalkorLib::Git.add(File.join(rootdir, files[:versionfile])) if FalkorLib::Git.init?(dir)
      end
      # === Gemset ===
      if files[:gemsetfile]
        default_gemset = File.basename(rootdir)
        if File.exists?( File.join( rootdir, files[:gemsetfile]))
          default_gemset = `cat #{File.join( rootdir, files[:gemsetfile])}`.chomp
        end
        g = options[:gemset] ? options[:gemset] : ask("Enter RVM gemset name for this directory", default_gemset)
        info " ==>  configuring RVM gemset file '#{files[:gemsetfile]}' with content '#{g}'"
        File.open( files[:gemsetfile], 'w') do |f|
          f.puts g
        end
        FalkorLib::Git.add(File.join(rootdir, files[:gemsetfile])) if FalkorLib::Git.init?(dir)
      end
    end # rvm




    ###### repo ######
    def repo(path = Dir.pwd)

    end # repo

  end # module Bootstrap
end # module FalkorLib
