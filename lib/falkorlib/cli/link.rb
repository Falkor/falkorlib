# -*- encoding: utf-8 -*-
################################################################################
# Time-stamp: <Mon 2020-04-20 17:12 svarrette>
################################################################################

require 'thor'
require 'falkorlib'
#require 'falkorlib/cli/init/repo'
#require "falkorlib/bootstrap"

module FalkorLib
  module CLI
    # Thor class for symlink creation
    class Link < ::Thor

      include FalkorLib::Common

      ###### commands ######
      desc "commands", "Lists all available commands", :hide => true
      def commands
        puts Link.all_commands.keys.sort - [ 'commands' ]
      end

      ###### rootdir (root beeing reserved) ######
      method_option :name, :aliases => ['--target', '-t', '-n'], :default => '.root', :desc => "Name of the symlink"
      #......................................
      desc "rootdir [options]", "Create a symlink '.root' which targets the root of the repository"
      def rootdir(dir = Dir.pwd)
        # TODO: find a generic way to handle help in subcommands
        # -- see https://github.com/erikhuda/thor/issues/532
        (help(__method__) and exit 0) if options[:help]
        FalkorLib::Bootstrap::Link.root(dir, options)
      end # rootdir


      ###### make ######
      method_option :latex, :default => true, :type => :boolean, :aliases => '-l',
                            :desc => "Makefile to compile LaTeX documents"
      method_option :gnuplot, :type => :boolean, :aliases => ['--plot', '-p'],
                              :desc => "Makefile to compile GnuPlot scripts"
      method_option :generic, :type => :boolean, :aliases => '-g',
                              :desc => "Generic Makefile for sub directory"
      method_option :markdown, :type => :boolean, :aliases => '-m',
                               :desc => "Makefile to convert Markdown files to HTML"
      method_option :images, :type => :boolean, :aliases => [ '-i', '--img' ],
                             :desc => "Makefile to optimize images"
      method_option :servers, :type => :boolean, :desc => "Makefile to fetch server files"
      method_option :refdir, :default => "#{FalkorLib.config[:git][:submodulesdir]}/Makefiles",
                             :aliases => '-d', :desc => "Path to Falkor's Makefile repository (Relative to Git root dir)"
      method_option :src, :type => :boolean, :aliases => [ '--src', '-s' ],
                          :desc => "Path to Falkor's Makefile for latex_src"
      #......................................
      desc "make [options]", "Create a symlink to one of Falkor's Makefile, set as Git submodule"
      def make(dir = Dir.pwd)
        (help(__method__) and exit 0) if options[:help]
        FalkorLib::Bootstrap::Link.makefile(dir, options)
      end # make


    end # class Link
  end # module CLI
end # module FalkorLib
