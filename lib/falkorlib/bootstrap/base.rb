# -*- encoding: utf-8 -*-
################################################################################
# Time-stamp: <Sam 2015-01-24 11:13 svarrette>
################################################################################
# Interface for the main Bootstrapping operations
#

require "falkorlib"
require "falkorlib/common"

include FalkorLib::Common

module FalkorLib  #:nodoc:
    module Config

        # Default configuration for Bootstrapping processes
        module Bootstrap
            DEFAULTS =
              {
               :trashdir => '.Trash',
               :types    => [ 'article', 'slides', 'gem', 'octopress', 'puppet_module', 'rvm' ],
               :rvm => {
                        :version     => '1.9.3',
                        :versionfile => '.ruby-version',
                        :gemsetfile  => '.ruby-gemset'
                       },
               :puppet   => {},
              }


        end
    end
end



module FalkorLib
    module Bootstrap
        module_function

        ###
        # Initialize a trash directory in path
        ##
        def trash(path = Dir.pwd, dirname = FalkorLib.config[:templates][:trashdir], options = {})
            #args = method(__method__).parameters.map { |arg| arg[1].to_s }.map { |arg| { arg.to_sym => eval(arg) } }.reduce Hash.new, :merge
            #ap args
            exit_status = 0
            trashdir = File.join(path, dirname)
            if Dir.exists?(trashdir)
                warning "The trash directory '#{dirname}' already exists"
                return 1
            end
            Dir.chdir(path) do
                info "creating the trash directory '#{dirname}'"
                exit_status = run %{
          mkdir -p #{dirname}
          echo '*' > #{dirname}/.gitignore
                }
                if FalkorLib::Git.init?(path)
                    exit_status = FalkorLib::Git.add(File.join(path, dirname, '.gitignore' ),
                                                     'Add Trash directory',
                                                     { :force => true } )
                end
            end
            exit_status.to_i
        end # trash

        ###### rvm ######
        # Initialize RVM in the current directory
        # Supported options:
        #  * :force       [boolean] force overwritting
        #  * :ruby        [string]  Ruby version to configure for RVM
        #  * :versionfile [string]  Ruby Version file
        #  * :gemset      [string]  RVM Gemset to configure
        #  * :gemsetfile  [string]  RVM Gemset file
        #  * :commit      [boolean] Commit the changes NOT YET USED
        ##
        def rvm(dir = Dir.pwd, options = {})
            info "Initialize Ruby Version Manager (RVM)"
            ap options if options[:debug]
            path = normalized_path(dir)
            use_git = FalkorLib::Git.init?(path)
            rootdir = use_git ? FalkorLib::Git.rootdir(path) : path
            files = {}
            exit_status = 1
            [:versionfile, :gemsetfile].each do |type|
                f = options[type.to_sym].nil? ? FalkorLib.config[:rvm][type.to_sym] : options[type.to_sym]
                if File.exists?( File.join( rootdir, f ))
                    content = `cat #{File.join( rootdir, f)}`.chomp
                    warning "The RVM file '#{f}' already exists (and contains '#{content}')"
                    next unless options[:force]
                    warning "... and it WILL BE overwritten"
                end
                files[type.to_sym] = f
            end
            # ==== Ruby version ===
            unless files[:versionfile].nil?
                file = File.join(rootdir, files[:versionfile])
                v =
                  options[:ruby] ?
                  options[:ruby] :
                  select_from(FalkorLib.config[:rvm][:rubies],
                              "Select RVM ruby to configure for this directory",
                              1)
                info " ==>  configuring RVM version file '#{files[:versionfile]}' for ruby version '#{v}'"
                File.open(file, 'w') do |f|
                    f.puts v
                end
                exit_status = (File.exists?(file) and `cat #{file}`.chomp == v) ? 0 : 1
                FalkorLib::Git.add(File.join(rootdir, files[:versionfile])) if use_git
            end
            # === Gemset ===
            if files[:gemsetfile]
                file = File.join(rootdir, files[:gemsetfile])
                default_gemset = File.basename(rootdir)
                default_gemset = `cat #{file}`.chomp if File.exists?( file )
                g = options[:gemset] ? options[:gemset] : ask("Enter RVM gemset name for this directory", default_gemset)
                info " ==>  configuring RVM gemset file '#{files[:gemsetfile]}' with content '#{g}'"
                File.open( File.join(rootdir, files[:gemsetfile]), 'w') do |f|
                    f.puts g
                end
                exit_status = (File.exists?(file) and `cat #{file}`.chomp == g) ? 0 : 1
                FalkorLib::Git.add(File.join(rootdir, files[:gemsetfile])) if use_git
            end
            exit_status
        end # rvm

        ###### repo ######
        # Initialize a Git repository for a project with my favorite layout
        # Supported options:
        # :interactive [boolean] Confirm Gitflow branch names
        # :master      [string]  Branch name for production releases
        # :develop     [string]  Branch name for development commits
        # :make        [boolean] Use a Makefile to pilot the repository actions
        # :rake        [boolean] Use a Rakefile (and FalkorLib) to pilot the repository action
        # :remote_sync [boolean] Operate a git remote synchronization
        ##
        def repo(name, options = {})
            ap options if options[:debug]
            path    = normalized_path(name)
            project = File.basename(path)
            use_git = FalkorLib::Git.init?(path)
            info "Bootstrap a [Git] repository for the project '#{project}'"
            if use_git
                warning "Git is already initialized for the repository '#{name}'"
                really_continue? unless options[:force]
            end
            info " ==> initialize Git flow in #{path}"
            FalkorLib::GitFlow.init(path, options)
            gitflow_branches = {}
            [ :master, :develop ].each do |t|
                gitflow_branches[t.to_sym] = FalkorLib::GitFlow.branches(t, path)
            end
            # === prepare Git submodules ===
            info " ==> prepare the relevant Git submodules"
            submodules = {
                          'gitstats' => { :url => 'https://github.com/hoxu/gitstats.git' }
                         }
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
                warning "TODO: setup Rakefile"
            end

            # === VERSION file ===
            FalkorLib::Bootstrap.versionfile(path, :tag => 'v0.0.0')

            #===== remote synchro ========
            if options[:remote_sync]
                remotes  = FalkorLib::Git.remotes(path)
                if remotes.include?( 'origin' )
                    info "perform remote synchronization"
                    [ :master, :develop ].each do |t|
                        FalkorLib::Git.publish(gitflow_branch[t.to_sym], path, 'origin')
                    end
                else
                    warning "no Git remote  'origin' found, thus no remote synchronization performed"
                end
            end

        end # repo

        ###### versionfile ######
        # Bootstrap a VERSION file at the root of a project
        # Supported options:
        # * :file    [string] filename
        # * :version [string] version to mention in the file
        ##
        def versionfile(dir = Dir.pwd, options = {})
            file    = options[:file]    ? options[:file]    : 'VERSION'
            version = options[:version] ? options[:version] : '0.0.0'
            info " ==> bootstrapping a VERSION file"
            path = normalized_path(dir)
            path = FalkorLib::Git.rootdir(path) if FalkorLib::Git.init?(path)
            unless Dir.exists?( path )
                warning "The directory #{path} does not exists and will be created"
                really_continue?
                FileUtils.mkdir_p path
            end
            #FalkorLib::Versioning.set_version()
            versionfile = File.join(path, file)
            unless File.exists?( versionfile )
                run %{  echo "#{version}" > #{versionfile} }
                if FalkorLib::Git.init?(path)
                    FalkorLib::Git.add(versionfile, "Initialize #{file} file")
                    Dir.chdir( path ) do
                        run %{ git tag #{options[:tag]} } if options[:tag]
                    end
                end
            else
                puts "  ... not overwriting the #{file} file which already exists"
            end
        end # versionfile

    end # module Bootstrap
end # module FalkorLib
