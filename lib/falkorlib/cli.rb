# -*- encoding: utf-8 -*-
################################################################################
# Time-stamp: <Ven 2015-01-16 11:45 svarrette>
################################################################################
# Interface for the CLI
#

#require "thor"
#require 'thor/group'

#require "thor/runner"

require 'falkorlib/cli/runner'

module FalkorLib

  # Falkor CLI Application, based on [Thor](http://whatisthor.com)
  module CLI

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
