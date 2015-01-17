# -*- encoding: utf-8 -*-
################################################################################
# Time-stamp: <Sam 2015-01-17 21:50 svarrette>
################################################################################

require 'thor'
require 'falkorlib'
#require 'falkorlib/cli/init/repo'

module FalkorLib
  module CLI

    class Init < ::Thor

      # attr_reader :options

      # def initialize(options)
      #   @options = options
      # end

      # ###### run ######
      # def run

      # end # run

      ###### latex ######
      desc "latex [options]", "Bootstrap a LaTeX project"
      def latex
        ap desc
      end # Bootstrap a LaTeX project

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
      #___________________
      def repo(name = '.')
        repo_path = (name == '.') ? Dir.pwd : File.join(Dir.pwd,  name)
        FalkorLib::Common.error "Already initialized repository" if FalkorLib::Git.init?(repo_path)
        FalkorLib::GitFlow::Init(repo_path)
        # Now prepare the template
        if options[:use_make]
          
        end
        if options[:use_rake]
          FalkorLib.config.gitflow do |c|
            c[:branches] = {
                            :master  => 'production',
                            :develop => 'devel'
                           }
          end
        end

      end
    end



  end # class Init
end # module CLI
end
