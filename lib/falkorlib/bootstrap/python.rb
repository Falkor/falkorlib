# -*- encoding: utf-8 -*-
################################################################################
# Time-stamp: <Wed 2018-11-21 11:46 svarrette>
################################################################################
# Interface for the main python Bootstrapping operations
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

    ###### pyenv ######
    # Initialize pyenv/direnv in the current directory
    # Supported options:
    #  * :force          [boolean] force overwritting
    #  * :python         [string]  Python version to configure for pyenv
    #  * :virtualenv     [string]  Python virtualenv name to configure
    #  * :versionfile    [string]  Python Version file
    #  * :virtualenvfile [string]  Python virtualenv file (specifying its name)
    #  * :direnvfile     [string]  Direnv configuration file
    #  * :commit         [boolean] Commit the changes NOT YET USED
    #  * :global         [boolean] Also configure the global direnv configuration
    #  .                           in ~/.config/direnv
    ##
    def pyenv(dir = Dir.pwd, options = {})
      info "Initialize Pyenv-virtualenv and direnv setup in '#{dir}'"
      ap options if options[:debug]
      path = normalized_path(dir)
      unless File.directory?(path)
        warning "The directory '#{path}' does not exist yet."
        warning 'Do you want to create (and git init) this directory?'
        really_continue?
        run %(mkdir -p #{path})
      end
      use_git = FalkorLib::Git.init?(path)
      rootdir = (use_git) ? FalkorLib::Git.rootdir(path) : path
      config =  FalkorLib::Config::DEFAULTS[:pyenv].clone
      files = {}   # list of files to create
      exit_status = 1
      # Specialize configuration
      [:versionfile, :virtualenvfile, :direnvfile].each do |k|
        #config[k] =  (options[k]) ? options[k] : ask("\t" + Kernel.format("%-20s", "#{k.to_s.capitalize.gsub!(/file/, ' filename')}"), config[k])
        config[k] = options[k] if options[k]
        if File.exist?( File.join( rootdir, config[k] ))
          content = `cat #{File.join( rootdir, config[k])}`.chomp
          warning "The python/pyenv file '#{config[k]}' already exists"
          warning "    (with content '#{content}')" unless k == :direnvfile
          next unless options[:force]
          warning "... and it WILL BE overwritten"
        end
        files[k] = config[k]
      end
      # ==== Python version ===
      unless files[:versionfile].nil?
        file = File.join(rootdir, config[:versionfile])
        config[:version] = FalkorLib.config[:pyenv][:version]
        if options[:python]
          config[:version] = options[:python]
        else
          config[:version] = select_from(FalkorLib.config[:pyenv][:versions],
                                         "Select Python pyenv version to configure for this directory",
                                         (FalkorLib.config[:pyenv][:versions].find_index(FalkorLib.config[:pyenv][:version]) + 1))
        end
        info " ==>  configuring pyenv version file '#{config[:versionfile]}' for python version '#{config[:version]}'"
        File.open(file, 'w') do |f|
          f.puts config[:version]
        end
        exit_status = (File.exist?(file) && (`cat #{file}`.chomp == config[:version])) ? 0 : 1
        FalkorLib::Git.add( file ) if use_git
      end
      # === Virtualenv ===
      if files[:virtualenvfile]
        file = File.join(rootdir, files[:virtualenvfile])
        default_virtualenv = File.basename(rootdir)
        default_virtualenv = `cat #{file}`.chomp if File.exist?( file )
        g = (options[:virtualenv]) ? options[:virtualenv] : ask("Enter virtualenv name for this directory", default_virtualenv)
        info " ==>  configuring virtualenv file '#{files[:virtualenvfile]}' with content '#{g}'"
        File.open( File.join(rootdir, files[:virtualenvfile]), 'w') do |f|
          f.puts g
        end
        exit_status = (File.exist?(file) && (`cat #{file}`.chomp == g)) ? 0 : 1
        FalkorLib::Git.add(File.join(rootdir, files[:virtualenvfile])) if use_git
      end
      # ==== Global direnvrc ====
      if options and options[:global]
        direnvrc     = config[:direnvrc]
        direnvrc_dir = File.dirname( direnvrc )
        unless File.directory?( direnvrc_dir )
          warning "The directory '#{direnvrc_dir}' meant for hosting the globa direnv settings does not exist"
          warning "About to create this directory"
          really_continue?
          run %(mkdir -p #{direnvrc_dir})
        end
        if (!File.exists?(direnvrc) or options[:force])
          templatedir = File.join( FalkorLib.templates, 'direnv')
          info " ==> configuring Global direnvrc #{files[:direnvrc]}"
          init_from_template(templatedir, direnvrc_dir, config,
                             :no_interaction => true,
                             :no_commit      => true,
                            )
        end
      end
      # ==== Local Direnv setup and .envrc ===
      if files[:direnvfile]
        envrc = File.join(rootdir, files[:direnvfile])
        setup = File.join(rootdir, 'setup.sh')
        if (!File.exists?(setup) or options[:force])
          templatedir = File.join( FalkorLib.templates, 'python')
          info " ==> configuring local direnv setup and #{files[:direnvfile]}"
          init_from_template(templatedir, rootdir, config,
                             :no_interaction => true,
                             :no_commit => true,
                            )
        end
        if (!File.exists?(envrc) or options[:force])
          run %(ln -s setup.sh #{envrc})
        end
        FalkorLib::Git.add( envrc ) if use_git
        FalkorLib::Git.add( setup ) if use_git
      end
      # Last motd
      warning <<-MOTD

----------------------------------------------------------------------------
Direnv/Pyenv configured for #{path}.
For more detailed instructions, see
     https://varrette.gforge.uni.lu/tutorials/pyenv.html

Now you probably need to perform the following actions:

    cd #{path}
    direnv allow .
    # Eventually install the pyenv version
    pyenv install #{config[:version]}

You can then enjoy your newly configured sand-boxed environment

    pip list
    pip install numpy scipy matplotlib
    pip install jupyter ipykernel
    python -m ipykernel install --user --name=$(head .python-virtualenv)
    jupyter notebook

To freeze your environment to pass it around

    pip freeze -l  # List all the pip packages used in the virtual environment
    pip freeze -l > requirements.txt  # Dump it to a requirements file
    git add requirements.txt
    git commit -s -m 'Python package list' requirements.txt

MOTD
      exit_status.to_i
    end # rvm

  end # module Bootstrap
end # module FalkorLib
