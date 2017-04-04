# -*- encoding: utf-8 -*-
################################################################################
# Time-stamp: <Tue 2017-04-04 11:42 svarrette>
################################################################################
# Interface for Bootstrapping various symlinks within your project
#
require "falkorlib"
require "falkorlib/common"
require "falkorlib/bootstrap"

require 'erb' # required for module generation
require 'artii'
require 'facter'

include FalkorLib::Common


module FalkorLib
  module Bootstrap
    # Hold [sim]link fonction creations
    module Link

      module_function

      ###### makefile ######
      # Create a symlink to the one of Falkor's Makefile, typically bring as a Git submodule
      # Supported options:
      #  * :force    [boolean] force action
      #  * :latex    [boolean] Makefile to compile LaTeX documents
      #  * :gnuplot  [boolean] Makefile to compile GnuPlot scripts
      #  * :markdown [boolean] Makefile to convert Markdown files to HTML
      #  * :servers  [boolean] Makefile to fetch key files from remote servers
      #  * :refdir   [string]  Path to Falkor's Makefile repository
      #  * :src      [boolean] Path to latex_src
      #  * :no_interaction [boolean] do not interact
      ##
      def makefile(dir = Dir.pwd,
                   options = {
                     :no_interaction => false
                   })
        raise FalkorLib::ExecError "Not used in a Git repository" unless FalkorLib::Git.init?
        exit_status = 0
        path = normalized_path(dir)
        rootdir = FalkorLib::Git.rootdir(path)
        info "Create a symlink to one of Falkor's Makefile"
        # Add Falkor's Makefiles
        submodules = FalkorLib.config[:git][:submodules]
        if submodules['Makefiles'].nil?
          submodules['Makefiles'] = {
            :url => 'https://github.com/Falkor/Makefiles.git',
            :branch => 'devel'
          }
        end
        FalkorLib::Git.submodule_init(rootdir, submodules)
        FalkorLib::Bootstrap::Link.root(dir)
        refdir = File.join(FalkorLib.config[:git][:submodulesdir], 'Makefiles')
        refdir = options[:refdir] unless options[:refdir].nil?
        dst        = File.join('.root', refdir)
        makefile_d = '.makefile.d'
        unless File.exist?(File.join(path, makefile_d))
          Dir.chdir( path ) do
            run %( ln -s #{dst} #{makefile_d} )
            FalkorLib::Git.add(makefile_d, "Add symlink '#{makefile_d}' to Falkor's Makefile directory")
          end
        end
        #ap options
        makefile = 'Makefile'
        type     = 'latex'
        # recall to place the default option (--latex) at the last position
        [ :gnuplot, :images, :generic, :markdown, :repo, :servers] .each do |e|
          if options[e.to_sym]
            type = e.to_s
            break
          end
        end
        type = 'latex_src' if options[:src]
        makefile = 'Makefile.insubdir' if options[:generic]
        makefile = 'Makefile.to_html'  if options[:markdown]
        dst = File.join(makefile_d, type, makefile)
        if File.exist?( File.join(path, 'Makefile'))
          puts "  ... Makefile already setup"
          exit_status = 1
        else
          info "Bootstrapping #{type.capitalize} Makefile (as symlink to Falkor's Makefile)"
          really_continue? unless options[:no_interaction]
          Dir.chdir( path ) do
            exit_status = run %( ln -s #{dst} Makefile )
            exit_status = FalkorLib::Git.add('Makefile', "Add symlink to the #{type.capitalize} Makefile")
          end
        end
        exit_status.to_i
      end # makefile_link

      ###### rootlink ######
      # Create a symlink '.root' targeting the relative path to the git root directory
      # Supported options:
      #  * :name [string] name of the symlink ('.root' by default)
      ##
      def root(dir = Dir.pwd, options = {})
        raise FalkorLib::ExecError "Not used in a Git repository" unless FalkorLib::Git.init?
        exit_status = 0
        path = normalized_path(dir)
        relative_path_to_root = (Pathname.new( FalkorLib::Git.rootdir(dir) ).relative_path_from Pathname.new( File.realpath(path)))
        if relative_path_to_root.to_s == "."
          FalkorLib::Common.warning "Already at the root directory of the Git repository"
          FalkorLib::Common.really_continue? unless options[:no_interaction]
        end
        target = (options[:name]) ? options[:name] : '.root'
        puts "Entering '#{relative_path_to_root}'"
        if File.exist?( File.join(path, target))
          puts "  ... the symbolic link '#{target}' already exists"
          exit_status = 1
        else
          warning "creating the symboling link '#{target}' which points to '#{relative_path_to_root}'" if options[:verbose]
          # Format: ln_s(old, new, options = {}) -- Creates a symbolic link new which points to old.
          #FileUtils.ln_s "#{relative_path_to_root}", "#{target}"
          Dir.chdir( path ) do
            exit_status = run %( ln -s #{relative_path_to_root} #{target} )
          end
          exit_status = FalkorLib::Git.add(File.join(path, target),
                                           "Add symlink to the root directory as .root")
        end
        exit_status.to_i
      end # rootlink


    end # module Link
  end # module Bootstrap
end # module FalkorLib
