# -*- encoding: utf-8 -*-
################################################################################
# Time-stamp: <Mon 2020-04-20 16:14 svarrette>
################################################################################

require 'thor'
require 'falkorlib'
#require 'falkorlib/cli/init/repo'
require "falkorlib/bootstrap"

module FalkorLib
  module CLI
    # Thor class for all bootstrapping / initialization
    class New < ::Thor

      package_name "Falkor[Lib] 'new'"
      namespace :new

      def self.banner(task, _namespace = true, subcommand = false)
        "#{basename} #{task.formatted_usage(self, true, subcommand)}"
      end

      ###### commands ######
      desc "commands", "Lists all available commands", :hide => true
      def commands
        puts New.all_commands.keys.sort - [ 'commands' ]
      end

      #map %w[--help -h] => :help

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
      method_option :git_flow, :default => true, :type => :boolean, :desc => 'Bootstrap the repository with Git-glow'
      method_option :make, :default => true,     :type => :boolean, :desc => 'Use a Makefile to pilot the repository actions'
      method_option :rake, :type => :boolean, :desc => 'Use a Rakefile (and FalkorLib) to pilot the repository actions'
      method_option :interactive, :aliases => '-i', :default => true,
                    :type => :boolean, :desc => "Interactive mode, in particular to confirm Gitflow branch names"
      method_option :remote_sync, :aliases => '-r',
                    :type => :boolean, :desc => "Operate a git remote synchronization with remote. By default, all commits stay local"
      method_option :master, :default => 'production', :banner => 'BRANCH', :desc => "Master Branch name for production releases"
      method_option :develop, :aliases => [ '-b', '--branch', '--devel'],
                    :default => 'devel', :banner => 'BRANCH', :desc => "Branch name for development commits"
      #method_option :latex, :aliases => '-l', :type => :boolean, :desc => "Initiate a LaTeX project"
      #method_option :gem,   :type => :boolean, :desc => "Initiate a Ruby gem project"
      method_option :ruby, :default => '2.1.10', :desc => "Ruby version to configure for RVM"
      method_option :rvm,    :type => :boolean, :desc => "Initiate a RVM-based Ruby project"
      method_option :mkdocs, :type => :boolean, :desc => "Initiate Mk Docs within your project"
      method_option :license,     :default => 'none',    :desc => "Open Source License to use within your project"
      method_option :licensefile, :default => 'LICENSE', :desc => "LICENSE File name"
      method_option :pyenv, :type => :boolean, :desc => "Initiate a pyenv-based Python project"
      method_option :python, :banner => 'VERSION', :aliases => [ '--pyenv', '-p' ],
                    :desc => 'Python version to configure / install for pyenv'
      method_option :virtualenv, :aliases => [ '--env', '-e' ],
                    :desc => 'Python virtualenv name to configure for this directory'
      #method_option :octopress, :aliases => ['-o', '--www'], :type => :boolean, :desc => "Initiate an Octopress web site"
      #___________________
      def repo(name = '.')
        options[:rvm] = true if options[:rake] || options[:gem]
        # _newrepo(name, options)
        FalkorLib::Bootstrap.repo(name, options)
      end # repo

      ###### articles ######
      method_option :name,  :aliases => '-n', :desc => 'Name of the LaTeX project'
      method_option :dir,   :aliases => '-d', :desc => 'Project directory (relative to the git root directory)'
      method_option :ieee,  :type => :boolean, :default => false, :desc => 'Use the IEEEtran style for IEEE conference'
      method_option :llncs, :type => :boolean, :default => false, :desc => 'Use the Springer LNCS style', :aliases => '--lncs'
      method_option :acm,   :type => :boolean, :default => false, :desc => 'Use the ACM style'
      # ......................................
      desc "article [options]", "Bootstrap a LaTeX Article"
      #___________________
      def article(path = Dir.pwd)
        FalkorLib::Bootstrap.latex(path, :article, options)
      end # article


      ###### letter ######
      method_option :name, :aliases => '-n', :desc => 'Name of the LaTeX project'
      method_option :dir,  :aliases => '-d', :desc => 'Project directory (relative to the git root directory)'
      #......................................
      desc "letter [options]", "LaTeX-based letter"
      #___________________
      def letter(path = Dir.pwd)
        FalkorLib::Bootstrap.latex(path, :letter, options)
      end # letter

      ###### license ######
      method_option :license,     :aliases => ['--lic' , '-l'], :desc => "Open Source License to use within your project"
      method_option :licensefile, :aliases => ['-f' ], :default => 'LICENSE', :desc => "LICENSE File name"
      #......................................
      desc "license [options]", "Generate an Open-Source License for your project"
      def license(path = Dir.pwd)
        license = options[:license] ?  options[:license] : FalkorLib::Bootstrap.select_licence('none')
        FalkorLib::Bootstrap.license(path, license, '', options)
      end # license

      ##### make ######
      method_option :repo, :type => :boolean, :aliases => '-r',
                    :desc => "Create a root Makefile piloting repository operations"
      method_option :latex, :type => :boolean, :aliases => '-l',
                    :desc => "Makefile to compile LaTeX documents"
      method_option :gnuplot, :type => :boolean, :aliases => ['--plot', '-p'],
                    :desc => "Makefile to compile GnuPlot scripts"
      method_option :generic, :type => :boolean, :aliases => '-g',
                    :desc => "Generic Makefile for sub directory"
      method_option :images, :type => :boolean, :aliases => [ '-i', '--img' ],
                    :desc => "Makefile to optimize images"
      method_option :src, :type => :boolean, :aliases => [ '--src', '-s' ],
                    :desc => "Path to Falkor's Makefile for latex_src"
      #......................................
      desc "make [options]", "Initiate one of Falkor's Makefile"
      def make(dir = Dir.pwd)
        if options[:repo]
          FalkorLib::Bootstrap.makefile(dir)
        elsif (options[:latex] or options[:gnuplot] or options[:generic] or options[:images] or options[:src])
          FalkorLib::Bootstrap::Link.makefile(dir, options)
        else
          FalkorLib::Common.error 'Kindly precize the type of Makefile you which to create'
        end
      end # make


      ###### pyenv ######
      desc "pyenv PATH [options]", "Initialize pyenv/direnv"
      long_desc <<-PYENV_LONG_DESC
Initialize  pyenv/direnv for the current directory (or at the root directory of the Git repository)
according to the configuration suggested on https://varrette.gforge.uni.lu/tutorials/pyenv.html

It consists of the following files:
\x5 * `.python-version`:    Project file hosting a single line for the expected python version
\x5 * `.python-virtualenv`: Virtualenv file hosting a single line for the virtualenv to use for this project
\x5 * `.envrc` (symlink to `setup.sh`): Direnv configuration meant to automatically activate the configured virtualenv when entering the directory (and deactivate when quitting).

These files will be committed in Git to ensure a consistent environment for the project.

Eventually (with the --global option enabled by default), the global direnvrc file will be setup for you (in `~/.config/direnv/direnvrc`)
PYENV_LONG_DESC
      method_option :force, :aliases => '-f',
                    :type => :boolean, :desc => 'Force overwritting the  pyenv/direnv config'
      method_option :python, :banner => 'VERSION', :aliases => [ '--pyenv', '-p' ],
                    :desc => 'Python version to configure / install for pyenv'
      method_option :versionfile, :banner => 'FILE',
                    :default => FalkorLib.config[:pyenv][:versionfile], :desc => 'Python Version file'
      method_option :virtualenv, :aliases => [ '--env', '-e' ],
                    :desc => 'Python virtualenv name to configure for this directory'
      method_option :virtualenvfile, :banner => 'FILE',
                    :default => FalkorLib.config[:pyenv][:gemsetfile], :desc => ' Python virtualenv filename'
      method_option :global, :aliases => '-g', :type => :boolean,
                    :default => true, :desc => 'Force overwritting the  pyenv/direnv config'
      #____________________
      def pyenv(path = '.')
        FalkorLib::Bootstrap.pyenv(path, options)
      end # pyenv


      ###### slides ######
      #......................................
      desc "slides [options]", "Bootstrap LaTeX Beamer slides"
      method_option :name, :aliases => '-n', :desc => 'Name of the LaTeX project'
      #method_option :dir,  :aliases => '-d', :desc => 'Project directory (relative to the git root directory)'
      #___________________
      def slides(path = Dir.pwd)
        FalkorLib::Bootstrap.latex(path, :beamer, options)
      end # slides

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
      method_option :version, :aliases => '-v',
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

    end # class New
  end # module CLI
end # module FalkorLib
