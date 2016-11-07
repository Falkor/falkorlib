# -*- encoding: utf-8 -*-
################################################################################
# Time-stamp: <Sat 2016-11-05 09:52 svarrette>
################################################################################
# Interface for the CLI
#

require 'thor'
require 'thor/actions'
require 'thor/group'
require 'thor/zsh_completion'

require "falkorlib"

require "falkorlib/cli/new"
require "falkorlib/cli/link"



module FalkorLib

  # Falkor CLI Application, based on [Thor](http://whatisthor.com)
  module CLI

    # Main Application
    class App < ::Thor
      package_name "Falkor[Lib]"
      map %w[--version -V] => :version

      namespace :falkor

      include Thor::Actions
      include FalkorLib::Common
      include ZshCompletion::Command

      #default_command :info

      class_option :verbose, :aliases => "-v",
                   :type => :boolean, :desc => "Enable verbose output mode"
      class_option :debug,
                   :type => :boolean, :default => FalkorLib.config[:debug], :desc => "Enable debug output mode"
      class_option :dry_run, :aliases => '-n', :desc => "Perform a trial run with (normally) no changes made",  :type => :boolean

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
      method_option :global, :aliases => '-g', :type => :boolean, :desc => 'Operate on the global configuration'
      method_option :local,  :aliases => '-l', :type => :boolean, :desc => 'Operate on the local configuration of the repository'
      def config(key = '')
        info "Thor options:"
        puts options.to_yaml
        info "FalkorLib internal configuration:"
        puts FalkorLib.config.to_yaml
      end # config

      #map %w[--help -h] => :help

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
      method_option :git_flow, :default => true, :type => :boolean, :desc => 'Bootstrap the repository with Git-glow'
      method_option :make, :default => true,     :type => :boolean, :desc => 'Use a Makefile to pilot the repository actions'
      method_option :rake,       :type => :boolean, :desc => 'Use a Rakefile (and FalkorLib) to pilot the repository actions'
      method_option :interactive, :aliases => '-i', :default => true,
                    :type => :boolean, :desc => "Interactive mode, in particular to confirm Gitflow branch names"
      method_option :remote_sync, :aliases => '-r',
                    :type => :boolean, :desc => "Operate a git remote synchronization with remote. By default, all commits stay local"
      method_option :master, :default => 'production', :banner => 'BRANCH', :desc => "Master Branch name for production releases"
      method_option :develop, :aliases => [ '-b', '--branch', '--devel'],
                    :default => 'devel', :banner => 'BRANCH', :desc => "Branch name for development commits"
      # method_option :latex, :aliases => '-l', :type => :boolean, :desc => "Initiate a LaTeX project"
      # #method_option :gem,   :type => :boolean, :desc => "Initiate a Ruby gem project"
      # method_option :rvm,   :type => :boolean, :desc => "Initiate a RVM-based Ruby project"
      # method_option :ruby, :default => '1.9.3', :desc => "Ruby version to configure for RVM"
      #method_option :pyenv, :type => :boolean, :desc => "Initiate a pyenv-based Python project"
      #method_option :octopress, :aliases => ['-o', '--www'], :type => :boolean, :desc => "Initiate an Octopress web site"
      #___________________
      def init(name = '.')
        #options[:rvm] = true if options[:rake] or options[:gem]
        # _newrepo(name, options)
        FalkorLib::Bootstrap.repo(name, options)
      end # repo

      ###### link <subcommand>  ######
      desc "link <TYPE> [<path>]", "Initialize a special symlink in <path> (the current directory by default)"
      subcommand "link", FalkorLib::CLI::Link


      ###### motd ######
      method_option :file,     :aliases => '-f', :default => '/etc/motd', :desc => "File storing the message of the day"
      method_option :width,    :aliases => '-w', :default => 80, :type => :numeric, :desc => "Width for the text"
      method_option :title,    :aliases => '-t', :desc => "Title to be placed in the motd (using asciify/figlet)"
      method_option :subtitle, :desc => "Eventual subtitle to place below the title"
      method_option :hostname, :desc => "Hostname"
      method_option :support,  :aliases => '-s', :desc => "Support/Contact mail"
      method_option :desc,     :aliases => '-d', :desc => "Short Description of the host"
      method_option :nodemodel,:aliases => '-n', :desc => "Node Model"
      #......................................
      desc "motd <PATH> [options]", "Initiate a 'motd' file - message of the day"
      def motd(path = '.')
        FalkorLib::Bootstrap.motd(path, options)
      end # motd

      ###### new <subcommand> ######
      desc "new <type> [<path>]", "Initialize the directory PATH with one of FalkorLib's template(s)"
      subcommand "new", FalkorLib::CLI::New


      ###### version ######
      desc "--version, -V", "Print the version number"
      def version
        say "Falkor[Lib] version " + FalkorLib::VERSION, :yellow # + "on ruby " + `ruby --version`
      end

    end # class App

    #puts Thor::ZshCompletion::Generator.new(App, "falkor").generate

  end # module CLI

end





# require_relative "commands/init"

# module FalkorLib
#   module CLI
#     def self.const_missing(c)
#       Object.const_get(c)
#     end
#   end
# end

# require 'falkorlib'


# require 'thor'
# require "thor/group"


#require "falkorlib/commands/init"

# require 'logger'

# # Declare a logger to log messages:
# LOGGER       = Logger.new(STDERR)
# LOGGER.level = Logger::INFO


# module FalkorLib
#   # Falkor CLI Application, based on [Thor](http://whatisthor.com)

#   require_relative "commands/init"

#   module CLI

#     def self.const_missing(c)
#       Object.const_get(c)
#     end


# # Main CLI command for FalkorLib
# class Command < Thor

#   class_option :verbose, :type => :boolean

#   require "falkorlib/commands/init"

#   # ----------
#   # desc "init <PATH> [options]", "Initialize the directory PATH with FalkorLib's template(s)"
#   # subcommand "init", FalkorLib::CLI::Init

# end # class FalkorLib::CLI::Command
#   end
# end




# # Mercenary version

# module FalkorLib

#   # Falkor CLI Application, based on (finally) [Mercenary](http://www.rubydoc.info/gems/mercenary)
#   # instead of [Thor](http://whatisthor.com)
#   class Command

#     # Keep a list of subclasses of FalkorLib::Command every time it's inherited
#     # Called automatically.
#     #
#     # base - the subclass
#     #
#     # Returns nothing
#     def self.inherited(base)
#       subclasses << base
#     end

#     # A list of subclasses of FalkorLib::Command
#     def self.subclasses
#       @subclasses ||= []
#     end

#     def init_with_program(p)
#       raise NotImplementedError.new("")
#     end
#   end
# end











# module FalkorLib  #:nodoc:
#   module Config

#     # Default configuration for FalkorLib::App
#     module CLI
#       # App defaults for FalkorLib
#       DEFAULTS = {
#                   # command-line options
#                   :options   => {},
#                   #:type      => "latex"
#                  }
#     end
#   end
# end


# # ---------------------------
# #    Command line parsing
# # ---------------------------
# module FalkorCLI
#   class Init < Thor
#     # # exit if bad parsing happen
#     # def self.exit_on_failure?
#     #   true
#     # end

#     class_option :verbose,
#       :type    => :boolean,
#       :default => false,
#       :aliases => "-v",
#       :desc    => "Verbose  mode"
#     class_option :debug,
#       :type    => :boolean,
#       :default => false,
#       :aliases => "-d",
#       :desc    => "Debug  mode"


#     desc "init", "Initialise a given template"
#     long_desc <<-LONGDESC
# Initialize a new directory according to <type> of template
#     LONGDESC
#     option :type,
#       :required => true,
#       :default  => 'repo',
#       :type     => :string,
#       :desc     => "Type of template to use to initialize this repository"
#     def init(type)
#       LOGGER.level = Logger::DEBUG if options[:verbose]
#       puts "Hello, world!"

#     end
#   end
# end # module FalkorLib
