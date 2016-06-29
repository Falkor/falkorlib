# -*- encoding: utf-8 -*-
################################################################################
# Time-stamp: <Wed 2016-06-29 14:41 svarrette>
################################################################################
# Interface for the CLI
#

require 'thor'
require 'thor/actions'
require 'thor/group'
require "falkorlib"

require "falkorlib/cli/new"
require "falkorlib/cli/link"



module FalkorLib

  # Falkor CLI Application, based on [Thor](http://whatisthor.com)
  module CLI

    # Main Application
    class App < ::Thor
      package_name "Falkor[Lib]"
      map "-V" => "version"

      namespace :falkor

      include Thor::Actions
      include FalkorLib::Common

      #default_command :info

      class_option :verbose, :aliases => "-v",
        :type => :boolean, :desc => "Enable verbose output mode"
      class_option :debug,
        :type => :boolean, :default => FalkorLib.config[:debug], :desc => "Enable debug output mode"
      class_option :dry_run, :aliases => '-n', :type => :boolean

      ###### commands ######
      # desc "commands", "Lists all available commands", :hide => true
      # def commands
      #   puts App.all_commands.keys - ["commands", "completions"]
      # end

      ###### config ######
      desc "config [option] [KEY]", "Print the current configuration of FalkorLib" #, :hide => true
      long_desc <<-CONFIG_LONG_DESC
This command allows you to interact with FalkorLib's configuration system.
FalkorLib retrieves its configuration from the local repository (in '<git_rootdir>/.falkor/config'),
environment variables (NOT YET IMPLEMENTED), and the user's home directory (~/.falkor/config), in that order of priority.
CONFIG_LONG_DESC
      method_option :global, :aliases => '-g', :type => :boolean, :desc => 'Operate on the global configuration (in ~/.falkor/config)'
      method_option :local,  :aliases => '-l', :type => :boolean, :desc => 'Operate on the local configuration of the repository (in <git_rootdir>/.falkor/config)'
      def config(key = '')
        info "Thor options:"
        puts options.to_yaml
        info "FalkorLib internal configuration:"
        puts FalkorLib.config.to_yaml
      end # config


      # map %w[--help -h] => :help

      ###### new ######
      desc "new <type> [<path>]", "Initialize the directory PATH with FalkorLib's template(s)"
      subcommand "new", FalkorLib::CLI::New

      ###### link  ######
      desc "link <type> [<path>]", "Initialize a special symlink in <path> (the current directory by default)"
      subcommand "link", FalkorLib::CLI::Link


      map %w[--version -V] => :version
      ###### version ######
      desc "--version, -V", "Print the version number"
      def version
        say "Falkor[Lib] version " + FalkorLib::VERSION, :yellow # + "on ruby " + `ruby --version`
      end




    end # class App
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
