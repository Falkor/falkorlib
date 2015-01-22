# -*- encoding: utf-8 -*-
################################################################################
# Time-stamp: <Jeu 2015-01-22 21:35 svarrette>
################################################################################

require 'thor'
require 'falkorlib'
#require 'falkorlib/cli/init/repo'
require "falkorlib/bootstrap"

module FalkorLib
  module CLI

    # Thor class for all bootstrapping / initialization
    class New < ::Thor

      ###### repo ######
      desc "repo NAME [options]", "Bootstrap a Git Repository"
      long_desc <<-REPO_LONG_DESC
Initiate a Git repository according to my classical layout.
\x5 * the repository will be configured according to the guidelines of [Git Flow]
\x5 * the high-level operations will be piloted either by a Makefile (default) or a Rakefile

By default, NAME is '.' meaning that the repository will be initialized in the current directory.
\x5Otherwise, the NAME subdirectory will be created and bootstraped accordingly.
      REPO_LONG_DESC
      #......................................................
      method_option :make, :default => true,
        :type => :boolean, :desc => 'Use a Makefile to pilot the repository actions'
      method_option :rake,
        :type => :boolean, :desc => 'Use a Rakefile (and FalkorLib) to pilot the repository actions'
      method_option :interactive, :aliases => '-i',
        :type => :boolean, :desc => "Interactive mode"
      method_option :remote_sync, :aliases => '-r',
        :type => :boolean, :desc => "Operate a git remote synchronization with remote. By default, all commits stay local"
      method_option :master, 
        :default => 'production', :banner => 'BRANCH', :desc => "Master Branch name for production releases"
      method_option :develop, :aliases => [ '-b', '--branch', '--devel'],
        :default => 'devel', :banner => 'BRANCH', :desc => "Branch name for development commits"
      #___________________
      def repo(name = '.')
       # _newrepo(name, options)
        FalkorLib::Bootstrap.repo(name, options)
      end # repo


      ###### trash ######
      desc "trash PATH", "Add a Trash directory"
      def trash(path = Dir.pwd)
        FalkorLib::Bootstrap.trash(path)
      end # trash

      ###### rvm ######
      method_option :force, :aliases => '-f',
        :type => :boolean, :desc => 'Force overwritting the RVM config'
      method_option :ruby, :banner => 'VERSION',
        :desc => 'Ruby version to configure / install for RVM'
      method_option :versionfile, :banner => 'FILE',
        :default => FalkorLib.config[:rvm][:versionfile], :desc => 'RVM ruby version file'
      method_option :gemset, :desc => 'RVM gemset to configure for this directory'
      method_option :gemsetfile, :banner => 'FILE',
        :default => FalkorLib.config[:rvm][:gemsetfile], :desc => 'RVM gemset file'
      #..........................................
      desc "rvm PATH [options]", "Initialize RVM"
      long_desc <<-RVM_LONG_DESC
Initialize Ruby Version Manager (RVM) for the current directory (or at the root directory of the Git repository).
It consists of two files:
\x5 * `.ruby-version`: Project file hosting a single line for the ruby version
\x5 * `.ruby-gemset`:  Gemset file hosting a single line for the gemset to use for this project

These files will be committed in Git to ensure a consistent environment for the project.
      RVM_LONG_DESC
      def rvm(path = '.')
        FalkorLib::Bootstrap.rvm(path, options)
      end # rvm
      
    end # class Init
  end # module CLI
end # module FalkorLib
