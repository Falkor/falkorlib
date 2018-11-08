# -*- encoding: utf-8 -*-
################################################################################
# Time-stamp: <Mon 2017-01-16 14:16 svarrette>
################################################################################
# Interface for the main Bootstrapping operations
#

require "falkorlib"
require "falkorlib/common"
require "falkorlib/bootstrap"

require 'erb' # required for module generation
require 'artii'
require 'facter'

include FalkorLib::Common


module FalkorLib
  module Bootstrap #:nodoc:

    module_function

    ###### repo ######
    # Initialize a Git repository for a project with my favorite layout
    # Supported options:
    # * :no_interaction [boolean]: do not interact
    # * :gitflow     [boolean]: bootstrap with git-flow
    # * :license     [string]  License to use
    # * :licensefile [string]  License filename (default: LICENSE)
    # * :interactive [boolean] Confirm Gitflow branch names
    # * :master      [string]  Branch name for production releases
    # * :develop     [string]  Branch name for development commits
    # * :make        [boolean] Use a Makefile to pilot the repository actions
    # * :rake        [boolean] Use a Rakefile (and FalkorLib) to pilot the repository action
    # * :remote_sync [boolean] Operate a git remote synchronization
    # * :latex       [boolean] Initiate a LaTeX project              **NOT YET IMPLEMENTED**
    # * :gem         [boolean] Initiate a Ruby gem project           **NOT YET IMPLEMENTED**
    # * :mkdocs      [boolean] Initiate MkDocs within your project
    # * :rvm         [boolean] Initiate a RVM-based Ruby project
    # * :pyenv       [boolean] Initiate a pyenv-based Python project **NOT YET IMPLEMENTED**
    # * :octopress   [boolean] Initiate an Octopress web site        **NOT YET IMPLEMENTED**
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
        if File.exist?( makefile )
          puts "  ... not overwriting the root Makefile which already exists"
        else
          src_makefile = File.join(path, FalkorLib.config.git[:submodulesdir],
                                   'Makefiles', 'repo', 'Makefile')
          FileUtils.cp src_makefile, makefile
          info "adapting Makefile to the gitflow branches"
          Dir.chdir( path ) do
            run %(
   sed -i '' \
        -e \"s/^GITFLOW_BR_MASTER=production/GITFLOW_BR_MASTER=#{gitflow_branches[:master]}/\" \
        -e \"s/^GITFLOW_BR_DEVELOP=devel/GITFLOW_BR_DEVELOP=#{gitflow_branches[:develop]}/\" \
        Makefile
                        )
          end
          FalkorLib::Git.add(makefile, 'Initialize root Makefile for the repo')
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
          write_from_erb_template(erbfiles, rakefile, {}, :srcdir => templatedir.to_s)
        end
      end

      # === VERSION file ===
      FalkorLib::Bootstrap.versionfile(path, :tag => 'v0.0.0') unless options[:gem]

      # === RVM ====
      FalkorLib::Bootstrap.rvm(path, options) if options[:rvm]

      # === README ===
      FalkorLib::Bootstrap.readme(path, options) # This should also save the project configuration
      # collect the set options
      local_config = FalkorLib::Config.get(path)

      # === MkDocs ===
      FalkorLib::Bootstrap.mkdocs(path, options) if options[:mkdocs]

      # === Licence ===
      if (local_config[:project] and local_config[:project][:license])
        author  = local_config[:project][:author] ? local_config[:project][:author] : FalkorLib::Config::Bootstrap::DEFAULTS[:metadata][:author]
        FalkorLib::Bootstrap.license(path, local_config[:project][:license], author,  options)
      end
      #


      #===== remote synchro ========
      if options[:remote_sync]
        remotes = FalkorLib::Git.remotes(path)
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

    ###### gitcrypt ######
    # Initialize git-crypt in the current directory
    # Supported options:
    #  * :force       [boolean] force overwritting
    #  * :owner       [string]  owner (GPG ID or email)
    #  * :keys        [array]   List of GPG IDs allowed to unlock the repository
    #  * :ulhpc       [boolean] setup the repository for the ULHPC team
    ##
    def gitcrypt(dir = Dir.pwd, options = {})
      path = normalized_path(dir)
      unless File.directory?(path)
        warning "The directory '#{path}' does not exist yet."
        warning 'Do you want to create (and git init) this directory?'
        really_continue?
        run %(mkdir -p #{path})
        FalkorLib::Git.init(path)
      end
      error "Not a git-ready directory" unless FalkorLib::Git.init?(path)
      rootdir = FalkorLib::Git.rootdir(path)
      config =  FalkorLib::Config::Bootstrap::DEFAULTS[:gitcrypt].clone
      info "about to initialize Git crypt for the repository '#{rootdir}'"
      really_continue?
      config[:owner] = (options[:owner]) ? options[:owner] :  ask("\tEmail or (better) GPG ID of the owner of the git-crypt (root) vault", config[:owner])
      [ :hooksdir ].each do |k|
        config[k] = (options[k]) ? options[k] : ask("\t#{k.capitalize}", config[k])
      end
      #puts config.to_yaml
      if File.exists?(File.join(rootdir, '.git/git-crypt/keys/default'))
        warning "git-crypt has already been initialised in '#{rootdir}'"
      else
        Dir.chdir( rootdir ) do
          run %( git crypt init )
          if config[:owner]
            info "setup owner of the git-crypt vault to '#{config[:owner]}'"
            run %( gpg --list-key  #{config[:owner]} | grep uid| head -n1)
            run %( git crypt add-gpg-user #{config[:owner]} )
          end
        end
      end
      # Bootstrap the directory
      gitattributes = File.join(rootdir, '.gitattributes')
      if File.exists?(gitattributes)
        puts "  ... '.gitattributes' file already exists"
      else
        templatedir = File.join( FalkorLib.templates, 'git-crypt')
        init_from_template(templatedir, rootdir, {},
                           :no_interaction => true,
                           :no_commit => false)
        FalkorLib::Git.add(gitattributes, 'Initialize .gitattributes for git-crypt')
      end

      git_hooksdir       = File.join(rootdir, '.git', 'hooks')
      precommit_hook     = File.join(git_hooksdir, 'pre-commit')
      src_git_hooksdir   = File.join(rootdir, config[:hooksdir])
      src_precommit_hook = File.join(src_git_hooksdir, config[:hook])
      if File.exists?(File.join(rootdir, config[:hook]))
        Dir.chdir( rootdir ) do
          run %(mkdir -p #{config[:hooksdir]} )
          unless File.exists?(src_precommit_hook)
            run %(mv #{config[:hook]} #{config[:hooksdir]}/ )
            run %(chmod +x #{config[:hooksdir]}/#{config[:hook]})
            FalkorLib::Git.add(src_precommit_hook, 'pre-commit hook for git-crypt')
          end
          run %(rm -f #{config[:hook]} ) if File.exists?(File.join(rootdir, config[:hook]))
        end
      end
      # Pre-commit hook
      unless File.exist?(precommit_hook)
        info "=> bootstrapping special Git pre-commit hook for git-crypt"
        relative_src_hooksdir = Pathname.new( File.realpath( src_git_hooksdir )).relative_path_from Pathname.new( git_hooksdir )
        Dir.chdir( git_hooksdir ) do
          run %(ln -s #{relative_src_hooksdir}/#{config[:hook]} pre-commit)
        end
      end
      gpgkeys = []
      gpgkeys = config[:ulhpc] if options[:ulhpc]
      gpgkeys = options[:keys] if options[:keys]
      gpgkeys.each do |k|
        Dir.chdir( rootdir ) do
          info "allow GPG ID '#{k}' to unlock the git-crypt vault"
          run %( gpg --list-key  #{k} | grep uid| head -n1)
          run %( git crypt add-gpg-user #{k} )
        end
      end




    end # gitcrypt

  end # module Bootstrap
end # module FalkorLib
