# -*- encoding: utf-8 -*-
################################################################################
# Time-stamp: <Mon 2020-04-20 17:04 svarrette>
################################################################################
# Interface for the CLI
#

require 'thor'
require 'thor/actions'
require 'thor/group'
#require 'thor/zsh_completion'

require 'falkorlib'

require 'falkorlib/cli/new'
require 'falkorlib/cli/link'
require 'falkorlib/cli/make'


module FalkorLib
  # Falkor CLI Application, based on [Thor](http://whatisthor.com)
  module CLI
    # Main Application
    class App < ::Thor

      # https://stackoverflow.com/questions/49042591/how-to-add-help-h-flag-to-thor-command
      def self.start(*args)
        if (Thor::HELP_MAPPINGS & ARGV).any? and subcommands.grep(/^#{ARGV[0]}/).empty?
          Thor::HELP_MAPPINGS.each do |cmd|
            if match = ARGV.delete(cmd)
              ARGV.unshift match
            end
          end
        end
        super
      end

      package_name 'Falkor[Lib]'
      map %w(--version -V) => :version
      map %w[--help -h] => :help

      namespace :falkor

      include Thor::Actions
      include FalkorLib::Common
      # include ZshCompletion::Command

      #default_command :info
      class_option :help, :aliases => ['-h', '--help'], type: :boolean
      class_option :verbose, :aliases => '-v', :type => :boolean,
                   :desc => "Enable verbose output mode"
      class_option :debug,   :type => :boolean, :default => FalkorLib.config[:debug],
                   :desc => "Enable debug output mode"
      class_option :dry_run, :aliases => '-n', :type => :boolean,
                   :desc => "Perform a trial run with (normally) no changes made"

      ###### commands ######
      desc "commands", "Lists all available commands"
      def commands
        puts App.all_commands.keys.sort - [ "zsh-completions"]
      end

      ###### config ######
      desc "config [option] [KEY]", "Print the current configuration of FalkorLib" #, :hide => true
      long_desc <<-CONFIG_LONG_DESC
This command allows you to interact with FalkorLib's configuration system.
FalkorLib retrieves its configuration from the local repository (in '<git_rootdir>/.falkor/config'),
environment variables (NOT YET IMPLEMENTED), and the user's home directory (<home>/.falkor/config), in that order of priority.
CONFIG_LONG_DESC
      method_option :global, :aliases => '-g', :type => :boolean,
                    :desc => 'Operate on the global configuration'
      method_option :local,  :aliases => '-l', :type => :boolean,
                    :desc => 'Operate on the local configuration of the repository'
      def config(_key = '')
        info "Thor options:"
        puts options.to_yaml
        info "FalkorLib internal configuration:"
        puts FalkorLib.config.to_yaml
      end # config



      ###### gitcrypt ######
      method_option :owner, :aliases => '-o',
                    :desc => "Email or (better) GPG ID of the owner of the git-crypt (root) vault"
      method_option :ulhpc, :aliases => '-u', :type => :boolean,
                    :desc => "Bootstrap git-crypt for the UL HPC team"
      method_option :keys, :type => :array, :aliases => [ '--gpgkeys', '-k' ],
                    :desc => "(space separated) List of GPG IDs allowed to unlock the repository"
      #......................................
      desc "gitcrypt <PATH> [options]", "Initialize git-crypt for the current repository"
      def gitcrypt(path = '.')
        FalkorLib::Bootstrap.gitcrypt(path, options)
      end # gitcrypt

      ###### init ######
      desc "init <PATH> [options]", "Bootstrap a Git Repository"
      long_desc <<-INIT_LONG_DESC
Initiate a Git repository according to my classical layout.
\x5 * the repository will be configured according to the guidelines of Git Flow
\x5 * the high-level operations will be piloted either by a Makefile (default) or a Rakefile

By default, <PATH> is '.' meaning that the repository will be initialized in the current directory.
\x5Otherwise, the NAME subdirectory will be created and bootstraped accordingly.
      INIT_LONG_DESC
      #......................................................
      method_option :git_flow, :default => true, :type => :boolean,
                    :desc => 'Bootstrap the repository with Git-glow'
      method_option :make, :default => true,     :type => :boolean,
                    :desc => 'Use a Makefile to pilot the repository actions'
      method_option :rake, :type => :boolean,
                    :desc => 'Use a Rakefile (and FalkorLib) to pilot the repository actions'
      method_option :interactive, :aliases => '-i', :default => true, :type => :boolean,
                    :desc => "Interactive mode, in particular to confirm Gitflow branch names"
      method_option :remote_sync, :aliases => '-r', :type => :boolean,
                    :desc => "Operate a git remote synchronization with remote. By default, all commits stay local"
      method_option :master, :default => 'production', :banner => 'BRANCH',
                    :desc => "Master Branch name for production releases"
      method_option :develop, :aliases => [ '-b', '--branch', '--devel'],
                    :default => 'devel', :banner => 'BRANCH',
                    :desc => "Branch name for development commits"
      # method_option :latex, :aliases => '-l', :type => :boolean, :desc => "Initiate a LaTeX project"
      # #method_option :gem,   :type => :boolean, :desc => "Initiate a Ruby gem project"
      # method_option :rvm,   :type => :boolean, :desc => "Initiate a RVM-based Ruby project"
      # method_option :ruby, :default => '1.9.3', :desc => "Ruby version to configure for RVM"
      # method_option :pyenv, :type => :boolean, :desc => "Initiate a pyenv-based Python project"
      # method_option :octopress, :aliases => ['-o', '--www'], :type => :boolean, :desc => "Initiate an Octopress web site"
      #___________________
      def init(name = '.')
        #options[:rvm] = true if options[:rake] or options[:gem]
        # _newrepo(name, options)
        FalkorLib::Bootstrap.repo(name, options)
      end # repo

      ###### link <subcommand>  ######
      desc "link <TYPE> [<path>]", "Initialize a special symlink in <path> (the current directory by default)"
      subcommand "link", FalkorLib::CLI::Link

      ###### mkdocs ######
      method_option :force, :aliases => '-f', :default => false, :type => :boolean,
                    :desc => "Force generation (might overwrite files)"
      #......................................
      desc "mkdocs [options]", "Initialize mkdocs for the current project"
      def mkdocs(path = '.')
        FalkorLib::Bootstrap.mkdocs(path, options)
      end # mkdocs

      ###### make <subcommand> ######
      desc "make <type> [<path>]", "Initialize one of Falkor's Makefile, typically bring as a symlink"
      subcommand "make", FalkorLib::CLI::Make


      ###### motd ######
      method_option :file,     :aliases => '-f', :default => '/etc/motd',
                    :desc => "File storing the message of the day"
      method_option :width,    :aliases => '-w', :default => 80, :type => :numeric,
                    :desc => "Width for the text"
      method_option :title,    :aliases => '-t',
                    :desc => "Title to be placed in the motd (using asciify/figlet)"
      method_option :subtitle, :desc => "Eventual subtitle to place below the title"
      method_option :hostname, :desc => "Hostname"
      method_option :support,  :aliases => '-s', :desc => "Support/Contact mail"
      method_option :desc,     :aliases => '-d', :desc => "Short Description of the host"
      method_option :nodemodel, :aliases => '-n', :desc => "Node Model"
      #......................................
      desc "motd <PATH> [options]", "Initiate a 'motd' file - message of the day"
      def motd(path = '.')
        FalkorLib::Bootstrap.motd(path, options)
      end # motd

      ###### new <subcommand> ######
      desc "new <type> [<path>]", "Initialize the directory PATH with one of FalkorLib's template(s)"
      subcommand "new", FalkorLib::CLI::New


      ###### vagrant ######
      #method_option :help, :aliases => '-h'
      method_option :force, :aliases => '-f', :default => false, :type => :boolean,
                    :desc => "Force generation (might overwrite files)"
      #......................................
      desc "vagrant [options]", "Initialize vagrant for the current project"
      def vagrant(path = '.')
        FalkorLib::Bootstrap.vagrant(path, options)
      end # vagrant

      ###### version ######
      desc "--version, -V", "Print the version number"
      def version
        say "Falkor[Lib] version " + FalkorLib::VERSION, :yellow # + "on ruby " + `ruby --version`
      end

    end # class App
    #puts Thor::ZshCompletion::Generator.new(App, "falkor").generate
  end # module CLI
end
