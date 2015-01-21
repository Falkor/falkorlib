# -*- encoding: utf-8 -*-
################################################################################
# Time-stamp: <Mer 2015-01-21 21:51 svarrette>
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
      method_option :use_make, :aliases => ['-m', '--make'],
        :type => :boolean, :default => true, :desc => 'Use a Makefile to pilot the repository actions'
      method_option :use_rake, :aliases => ['-r', '--rake'],
        :type => :boolean, :desc => 'Use a Rakefile (and FalkorLib) to pilot the repository actions'
      method_option :git_flow,
        :type => :boolean, :default => true, :desc => 'Initiate with git-flow'
      method_option :branch_prod, :default => 'production', :desc => "Branch name for production releases"
      method_option :branch_master, :default => 'devel',    :desc => "Branch name for development commits"
      #___________________
      def repo(name = '.')
        _newrepo(name, options)

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
      def rvm(path = Dir.pwd)
        FalkorLib::Bootstrap.rvm(path, options)
      end # rvm
      
      private
      ###### _newrepo(name, options) ######
      def _newrepo(name, options)

        repo_path = Dir.pwd
        if name == '.'
          repo_path = Dir.pwd
        elsif
          repo_path = (name =~ /^\//) ? name : File.join(Dir.pwd,  name)
        end
        FalkorLib::Common.error "Already initialized repository" if FalkorLib::Git.init?(repo_path)

        FalkorLib::GitFlow.init(repo_path) unless options[:dry_run]
        # Now prepare the template
        FalkorLib.config.git[:submodules]['gitstats'] =   { :url => 'https://github.com/hoxu/gitstats.git' }
        if options[:use_make]
          FalkorLib.config.git[:submodules]['Makefile'] = { :url => 'https://github.com/Falkor/Makefiles.git' }
        end
        if options[:use_rake]
          FalkorLib.config.gitflow do |c|
            c[:branches] = {
                            :master  => options[:branch_prod],
                            :develop => options[:branch_master]
                           }
          end
        end
        ap FalkorLib.config
      end # _newrepo(name, options)



    end # class Init
  end # module CLI
end # module FalkorLib
