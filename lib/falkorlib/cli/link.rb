# -*- encoding: utf-8 -*-
################################################################################
# Time-stamp: <Thu 2015-10-22 20:16 svarrette>
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

            ###### rootdir (root beeing reserved) ######
            method_option :name, :aliases => ['--target', '-t', '-n'], :default => '.root', :desc => "Name of the symlink"
            #......................................
            desc "rootdir [options]", "Create a symlink '.root' which targets the root of the repository"
            def rootdir(dir = Dir.pwd)
                FalkorLib::Bootstrap.rootlink(dir, options)
            end # rootdir


            ###### make ######
            method_option :latex, :default => true, :type => :boolean, :aliases => '-l', :desc => "Makefile to compile LaTeX documents"
            method_option :gnuplot, :type => :boolean, :aliases => ['--plot', '-g', '-p'], :desc => "Makefile to compile GnuPlot scripts"
            method_option :markdown, :type => :boolean, :aliases => '-m', :desc => "Makefile to convert Markdown files to HTML"
            method_option :markdown, :type => :boolean, :aliases => '-m', :desc => "Makefile to convert Markdown files to HTML"
            method_option :repo, :default => "#{FalkorLib.config[:git][:submodulesdir]}/Makefiles",
              :aliases => '-r', :desc => "Path to Falkor's Makefile repository (Relative to Git root dir)"
            method_option :target, :aliases => '-t', :desc => "Symlink target"
            #......................................
            desc "make [options]", "Create a symlink to one of Falkor's Makefile, set as Git submodule"
            def make(dir = Dir.pwd)
                FalkorLib::Bootstrap.makefile_link(dir, options)
            end # make


        end # class Link
    end # module CLI
end # module FalkorLib
