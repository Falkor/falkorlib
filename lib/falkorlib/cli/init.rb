# -*- encoding: utf-8 -*-
################################################################################
# Time-stamp: <Lun 2015-01-19 17:50 svarrette>
################################################################################

require 'thor'
require 'falkorlib'
#require 'falkorlib/cli/init/repo'

module FalkorLib
  module CLI

    # Thor class for all bootstrapping / initialization 
    class Init < ::Thor
      


      
      # ###### latex ######
      # desc "latex [options]", "Bootstrap a LaTeX project"
      # def latex
      #   ap desc
      # end # Bootstrap a LaTeX project

      ###### repo ######
      desc "repo NAME [options]", "Bootstrap a Git Repository"
      long_desc <<-REPO_LONG_DESC
Initiate a Git repository according to my classical layout.
\x5 * the repository will be configured according to the guidelines of [Git Flow]
\x5 * the high-level operations will be piloted either by a Makefile (default) or a Rakefile

By default, NAME is '.' meaning that the repository will be initialized in the current directory.
\x5Otherwise, the NAME subdirectory will be created and bootstraped accordingly.
      REPO_LONG_DESC


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
