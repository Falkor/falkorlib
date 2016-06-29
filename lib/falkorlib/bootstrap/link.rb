# -*- encoding: utf-8 -*-
################################################################################
# Time-stamp: <Sun 2016-03-27 23:58 svarrette>
################################################################################
# Interface for Bootstrapping various symlinks within your project
#
require "falkorlib"
require "falkorlib/common"
require 'erb'      # required for module generation
require 'artii'
require 'facter'

include FalkorLib::Common


module FalkorLib
    module Bootstrap
        module Link

            module_function

            ###### makefile ######
            # Create a symlink to the one of Falkor's Makefile, typically bring as a Git submodule
            # Supported options:
            #  * :force    [boolean] force action
            #  * :latex    [boolean] Makefile to compile LaTeX documents
            #  * :gnuplot  [boolean] Makefile to compile GnuPlot scripts
            #  * :markdown [boolean] Makefile to convert Markdown files to HTML
            #  * :refdir   [string]  Path to Falkor's Makefile repository
            #  * :src      [boolean] Path to latex_src
            ##
            def makefile(dir = Dir.pwd, options = {})
                path   = normalized_path(dir)
                rootdir = FalkorLib::Git.rootdir(path)
                info "Create a symlink to the one of Falkor's Makefile"
                # Add Falkor's Makefiles
                submodules = FalkorLib.config[:git][:submodules]
                submodules['Makefiles'] = {
                    :url   => 'https://github.com/Falkor/Makefiles.git',
                    :branch => 'devel'
                } if submodules['Makefiles'].nil?
                FalkorLib::Git.submodule_init(rootdir, submodules)
                FalkorLib::Bootstrap::Link.root(dir)
                dst        = File.join('.root', options[:refdir])
                makefile_d = '.makefile.d'
                unless File.exists?(File.join(path, makefile_d))
                    Dir.chdir( path ) do
                        run %{ ln -s #{dst} #{makefile_d} }
                        FalkorLib::Git.add(File.join(path, makefile_d), "Add symlink '#{makefile_d}' to Falkor's Makefile directory")
                    end
                end
                #ap options
                makefile = 'Makefile'
                type     = 'latex'
                # recall to place the default option (--latex) at the last position
                [ :gnuplot, :images, :generic, :markdown] .each do |e|
                    if options[e.to_sym]
                        type = e.to_s
                        break
                    end
                end
                type = 'latex_src' if options[:src]
                makefile = 'Makefile.insubdir' if options[:generic]
                makefile = 'Makefile.to_html'  if options[:markdown]
                dst = File.join(makefile_d, type, makefile)
                unless File.exists?( File.join(path, 'Makefile'))
                    info "Bootstrapping #{type.capitalize} Makefile (as symlink to Falkor's Makefile)"
                    really_continue?
                    Dir.chdir( path ) do
                        run %{ ln -s #{dst} Makefile }
                    end
                    #ap File.join(path, 'Makefile')
                    FalkorLib::Git.add(File.join(path, 'Makefile'), "Add symlink to the #{type.capitalize} Makefile")
                else
                    puts "  ... Makefile already setup"
                end
            end # makefile_link

            ###### rootlink ######
            # Create a symlink '.root' targeting the relative path to the git root directory
            # Supported options:
            #  * :name [string] name of the symlink ('.root' by default)
            ##
            def root(dir = Dir.pwd, options = {})
                raise FalkorLib::ExecError "Not used in a Git repository" unless FalkorLib::Git.init?
                path  = normalized_path(dir)
                relative_path_to_root = (Pathname.new( FalkorLib::Git.rootdir(dir) ).relative_path_from Pathname.new( File.realpath(path)))
                if "#{relative_path_to_root}" == "."
                    FalkorLib::Common.warning "Already at the root directory of the Git repository"
                    FalkorLib::Common.really_continue?
                end
                target = options[:name] ? options[:name] : '.root'
                puts "Entering '#{relative_path_to_root}'"
                unless File.exists?( File.join(path, target))
                    warning "creating the symboling link '#{target}' which points to '#{relative_path_to_root}'" if options[:verbose]
                    # Format: ln_s(old, new, options = {}) -- Creates a symbolic link new which points to old.
                    #FileUtils.ln_s "#{relative_path_to_root}", "#{target}"
                    Dir.chdir( path ) do
                        run %{ ln -s #{relative_path_to_root} #{target} }
                    end
                    FalkorLib::Git.add(File.join(path, target), "Add symlink to the root directory as .root")
                else
                    puts "  ... the symbolic link '#{target}' already exists"
                end
            end # rootlink


        end # module Link
    end # module Bootstrap
end # module FalkorLib
