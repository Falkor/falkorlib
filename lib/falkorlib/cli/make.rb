# -*- encoding: utf-8 -*-
################################################################################
# Time-stamp: <Thu 2018-11-08 16:50 svarrette>
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
        FalkorLib::Bootstrap.makefile(dir, options)
      end # repo


      ###### latex ######
      desc "latex", "Symlink to a Makefile to compile LaTeX documents"
      def latex(dir = Dir.pwd)
         FalkorLib::Bootstrap::Link.makefile(dir, :latex => true)
      end # latex

      ##### gnuplot #####
      desc "gnuplot", "Symlink to a Makefile to compile GnuPlot scripts"
      def gnuplot(dir = Dir.pwd)
         FalkorLib::Bootstrap::Link.makefile(dir, :gnuplot => true)
      end # gnuplot

      ##### generic #####
      desc "generic", "Symlink to Generic Makefile for sub directory"
      def generic(dir = Dir.pwd)
        FalkorLib::Bootstrap::Link.makefile(dir, :generic => true)
      end # generic

    end # class Make
  end # module CLI
end # module FalkorLib
