# -*- encoding: utf-8 -*-
################################################################################
# Time-stamp: <Mer 2015-02-25 00:05 svarrette>
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
      method_option :latex, :aliases => '-l', :type => :boolean, :desc => "Initiate a LaTeX project"
      method_option :gem,   :type => :boolean, :desc => "Initiate a Ruby gem project"
      method_option :rvm,   :type => :boolean, :desc => "Initiate a RVM-based Ruby project"
      method_option :pyenv, :type => :boolean, :desc => "Initiate a pyenv-based Python project"
      method_option :octopress, :aliases => ['-o', '--www'], :type => :boolean, :desc => "Initiate an Octopress web site"
      #___________________
      def repo(name = '.')
       # _newrepo(name, options)
        FalkorLib::Bootstrap.repo(name, options)
      end # repo


      ###### trash ######
      desc "trash PATH", "Add a Trash directory"
      #________________________
      def trash(path = Dir.pwd)
        FalkorLib::Bootstrap.trash(path)
      end # trash

      ###### rvm ######
      desc "rvm PATH [options]", "Initialize RVM"
      long_desc <<-RVM_LONG_DESC
Initialize Ruby Version Manager (RVM) for the current directory (or at the root directory of the Git repository).
It consists of two files:
\x5 * `.ruby-version`: Project file hosting a single line for the ruby version
\x5 * `.ruby-gemset`:  Gemset file hosting a single line for the gemset to use for this project

These files will be committed in Git to ensure a consistent environment for the project.
      RVM_LONG_DESC
      method_option :force, :aliases => '-f',
        :type => :boolean, :desc => 'Force overwritting the RVM config'
      method_option :ruby, :banner => 'VERSION',
        :desc => 'Ruby version to configure / install for RVM'
      method_option :versionfile, :banner => 'FILE',
        :default => FalkorLib.config[:rvm][:versionfile], :desc => 'RVM ruby version file'
      method_option :gemset, :desc => 'RVM gemset to configure for this directory'
      method_option :gemsetfile, :banner => 'FILE',
        :default => FalkorLib.config[:rvm][:gemsetfile], :desc => 'RVM gemset file'
      #____________________
      def rvm(path = '.')
        FalkorLib::Bootstrap.rvm(path, options)
      end # rvm

      ###### versionfile ######
      desc "versionfile PATH [options]", "initiate a VERSION file"
      method_option :file, :aliases => '-f',
        :desc => "Set the VERSION filename"
      method_option :tag,  :aliases => '-t',
        :desc => "Git tag to use"
      method_option :version,  :aliases => '-v',
        :desc => "Set the version to initialize in the version file"
      #_______________
      def versionfile(path = '.')
          FalkorLib::Bootstrap.versionfile(path, options)
      end # versionfile


      ###### readme ######
      method_option :make, :default => true,
        :type => :boolean, :desc => 'Use a Makefile to pilot the repository actions'
      method_option :rake,
        :type => :boolean, :desc => 'Use a Rakefile (and FalkorLib) to pilot the repository actions'
      method_option :latex, :aliases => '-l', :type => :boolean, :desc => "Describe a LaTeX project"
      method_option :gem,   :type => :boolean, :desc => "Describe a Ruby gem project"
      method_option :rvm,   :type => :boolean, :desc => "Describe a RVM-based Ruby project"
      method_option :pyenv, :type => :boolean, :desc => "Describe a pyenv-based Python project"
      method_option :octopress, :aliases => '--www', :type => :boolean, :desc => "Describe an Octopress web site"
      #......................................
      desc "readme PATH [options]", "Initiate a README file in the PATH directory ('./' by default)"
      def readme(path = '.')
          FalkorLib::Bootstrap.readme(path, options)
      end # readme
    end # class Init
  end # module CLI
end # module FalkorLib
