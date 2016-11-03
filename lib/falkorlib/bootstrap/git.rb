# -*- encoding: utf-8 -*-
################################################################################
# Time-stamp: <Thu 2016-11-03 00:53 svarrette>
################################################################################
# Interface for the main Bootstrapping operations
#

require "falkorlib"
require "falkorlib/common"
require "falkorlib/bootstrap"

require 'erb'      # required for module generation
require 'artii'
require 'facter'

include FalkorLib::Common


module FalkorLib
    module Bootstrap
        module_function

        ###### repo ######
        # Initialize a Git repository for a project with my favorite layout
        # Supported options:
        # * :no_interaction [boolean]: do not interact
        # * :gitflow     [boolean]: bootstrap with git-flow
        # * :interactive [boolean] Confirm Gitflow branch names
        # * :master      [string]  Branch name for production releases
        # * :develop     [string]  Branch name for development commits
        # * :make        [boolean] Use a Makefile to pilot the repository actions
        # * :rake        [boolean] Use a Rakefile (and FalkorLib) to pilot the repository action
        # * :remote_sync [boolean] Operate a git remote synchronization
        # * :latex       [boolean] Initiate a LaTeX project
        # * :gem         [boolean] Initiate a Ruby gem project
        # * :rvm         [boolean] Initiate a RVM-based Ruby project
        # * :pyenv       [boolean] Initiate a pyenv-based Python project
        # * :octopress   [boolean] Initiate an Octopress web site
        ##
        def repo(name, options = {})
            ap options if options[:debug]
            path    = normalized_path(name)
            project = File.basename(path)
            use_git = FalkorLib::Git.init?(path)
            if options[:rake]
                options[:make] = false
                options[:rvm]  = true
            end
            info "Bootstrap a [Git] repository for the project '#{project}'"
            if use_git
                warning "Git is already initialized for the repository '#{name}'"
                really_continue? unless options[:force]
            end
            if options[:git_flow]
                info " ==> initialize Git flow in #{path}"
                FalkorLib::GitFlow.init(path, options)
                gitflow_branches = {}
                [ :master, :develop ].each do |t|
                    gitflow_branches[t.to_sym] = FalkorLib::GitFlow.branches(t, path)
                end
            else
                FalkorLib::Git.init(path, options)
            end
            # === prepare Git submodules ===
            info " ==> prepare the relevant Git submodules"
            submodules = {}
            #'gitstats' => { :url => 'https://github.com/hoxu/gitstats.git' }
            #             }
            if options[:make]
                submodules['Makefiles'] = {
                                           :url    => 'https://github.com/Falkor/Makefiles.git',
                                           :branch => 'devel'
                                          }
            end
            FalkorLib::Git.submodule_init(path, submodules)
            # === Prepare root [M|R]akefile ===
            if options[:make]
                info " ==> prepare Root Makefile"
                makefile = File.join(path, "Makefile")
                unless File.exist?( makefile )
                    src_makefile = File.join(path, FalkorLib.config.git[:submodulesdir],
                                             'Makefiles', 'repo', 'Makefile')
                    FileUtils.cp src_makefile, makefile
                    info "adapting Makefile to the gitflow branches"
                    Dir.chdir( path ) do
                        run %{
   sed -i '' \
        -e \"s/^GITFLOW_BR_MASTER=production/GITFLOW_BR_MASTER=#{gitflow_branches[:master]}/\" \
        -e \"s/^GITFLOW_BR_DEVELOP=devel/GITFLOW_BR_DEVELOP=#{gitflow_branches[:develop]}/\" \
        Makefile
                        }
                    end
                    FalkorLib::Git.add(makefile, 'Initialize root Makefile for the repo')
                else
                    puts "  ... not overwriting the root Makefile which already exists"
                end
            end
            if options[:rake]
                info " ==> prepare Root Rakefile"
                rakefile = File.join(path, "Rakefile")
                unless File.exist?( rakefile )
                    templatedir = File.join( FalkorLib.templates, 'Rakefile')
                    erbfiles = [ 'header_rakefile.erb' ]
                    erbfiles << 'rakefile_gitflow.erb' if FalkorLib::GitFlow.init?(path)
                    erbfiles << 'footer_rakefile.erb'
                    write_from_erb_template(erbfiles, rakefile, {}, { :srcdir => "#{templatedir}" })
                end
            end

            # === VERSION file ===
            FalkorLib::Bootstrap.versionfile(path, :tag => 'v0.0.0')

            # === RVM ====
            FalkorLib::Bootstrap.rvm(path, options) if options[:rvm]

            # === README ===
            FalkorLib::Bootstrap.readme(path, options)

            #===== remote synchro ========
            if options[:remote_sync]
                remotes  = FalkorLib::Git.remotes(path)
                if remotes.include?( 'origin' )
                    info "perform remote synchronization"
                    [ :master, :develop ].each do |t|
                        FalkorLib::Git.publish(gitflow_branches[t.to_sym], path, 'origin')
                    end
                else
                    warning "no Git remote  'origin' found, thus no remote synchronization performed"
                end
            end

        end # repo



    end # module Bootstrap
end # module FalkorLib
