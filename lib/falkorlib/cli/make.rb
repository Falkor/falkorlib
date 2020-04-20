# -*- encoding: utf-8 -*-
################################################################################
# Time-stamp: <Mon 2020-04-20 17:11 svarrette>
################################################################################

require 'thor'
require 'falkorlib'
#require 'falkorlib/cli/init/repo'
#require "falkorlib/bootstrap"

module FalkorLib
  module CLI
    # Thor class for symlink creation
    class Make < ::Thor

      include FalkorLib::Common
      class_option :help, :aliases => ['-h', '--help'], type: :boolean

      ###### commands ######
      desc "commands", "Lists all available commands", :hide => true
      def commands
        puts Make.all_commands.keys.sort - [ 'commands' ]
      end

      ###### repo  ######
      method_option :master, :aliases => ['--production', '-m', '-p'],
                    :desc => 'Git flow master/production branch'
      method_option :develop, :aliases => ['--devel', '-d'],
                    :desc => 'Git flow development branch'
      #......................................
      desc "repo", "Create a root Makefile piloting repository operations"
      def repo(dir = Dir.pwd)
        # TODO: find a generic way to handle help in subcommands
        # -- see https://github.com/erikhuda/thor/issues/532
        (help(__method__) and exit 0) if options[:help]
        FalkorLib::Bootstrap.makefile(dir, options)
      end # repo


      ###### latex ######
      desc "latex", "Symlink to a Makefile to compile LaTeX documents"
      def latex(dir = Dir.pwd)
        (help(__method__) and exit 0) if options[:help]
         FalkorLib::Bootstrap::Link.makefile(dir, :latex => true)
      end # latex

      ###### src ######
      desc "src", "Symlink to a Makefile to recursively compile anything under src/"
      def src(dir = Dir.pwd)
        (help(__method__) and exit 0) if options[:help]
         FalkorLib::Bootstrap::Link.makefile(dir, :src => true)
      end # latex_src

      ##### gnuplot #####
      desc "gnuplot", "Symlink to a Makefile to compile GnuPlot scripts"
      def gnuplot(dir = Dir.pwd)
        (help(__method__) and exit 0) if options[:help]
         FalkorLib::Bootstrap::Link.makefile(dir, :gnuplot => true)
      end # gnuplot

      ##### generic #####
      desc "generic", "Symlink to Generic Makefile for sub directory"
      def generic(dir = Dir.pwd)
        (help(__method__) and exit 0) if options[:help]
        FalkorLib::Bootstrap::Link.makefile(dir, :generic => true)
      end # generic

    end # class Make
  end # module CLI
end # module FalkorLib
