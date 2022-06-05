# -*- encoding: utf-8 -*-
################################################################################
# Time-stamp: <Thu 2022-06-02 19:14 svarrette>
################################################################################
# FalkorLib Configuration
#
# Resources:
#  * https://github.com/markbates/cover_me/blob/master/lib/cover_me/config.rb
################################################################################
require "falkorlib"

require "configatron"
require "configatron/store"
require "deep_merge"

module FalkorLib #:nodoc:

  class << self

    # Yields up a configuration object when given a block.
    # Without a block it just returns the configuration object.
    # Uses Configatron under the covers.
    #
    # Example:
    #   FalkorLib.config do |c|
    #     c.foo = :bar
    #   end
    #
    #   FalkorLib.config.foo # => :bar
    def config
      yield configuration if block_given?
      configuration
    end

    ## initiate the configuration (with default value) if needed
    def configuration
      @config ||= Configatron::Store.new(FalkorLib::Config.default)
    end

  end


  module Config #:nodoc:

    # Defaults global settings
    DEFAULTS = {
      :debug          => false,
      :verbose        => false,
      :no_interaction => false,
      :root           => Dir.pwd,
      :config_files   => {
        :local   => '.falkor/config',
        :private => '.falkor/private',
        #:project => '.falkor/project',
      },
      #:custom_cfg   => '.falkorlib.yaml',
      :rvm => {
        # See https://www.ruby-lang.org/en/downloads/branches/ for stable branches
        :rubies      => [ '3.1.2', '3.0.4', '2.7.6'],
        :version     => '3.1.2',
        :versionfile => '.ruby-version',
        :gemsetfile  => '.ruby-gemset'
      },
      :pyenv => {
        # See https://devguide.python.org/#status-of-python-branches
        :versions       => ['3.9.13', '3.8.13', '3.7.13', '2.7.18' ],
        :version        => '3.7.13',
        :versionfile    => '.python-version',
        :virtualenvfile => '.python-virtualenv',
        :direnvfile     => '.envrc',
        :direnvrc       => File.join( ENV['HOME'], '.config', 'direnv', 'direnvrc')
      },
      :templates => {
        :trashdir => '.Trash',
        :puppet   => {}
      },
      :tokens  => { :code_climate => '' },
      :project => {},
    }

    module_function

    ## Build the default configuration hash, to be used to initiate the default.
    # The hash is built depending on the loaded files.
    def default
      res = FalkorLib::Config::DEFAULTS.clone
      $LOADED_FEATURES.each do |path|
        res[:git]        = FalkorLib::Config::Git::DEFAULTS        if path.include?('lib/falkorlib/git.rb')
        res[:gitflow]    = FalkorLib::Config::GitFlow::DEFAULTS    if path.include?('lib/falkorlib/git.rb')
        res[:versioning] = FalkorLib::Config::Versioning::DEFAULTS if path.include?('lib/falkorlib/versioning.rb')
        if path.include?('lib/falkorlib/puppet.rb')
          res[:puppet] = FalkorLib::Config::Puppet::DEFAULTS
          res[:templates][:puppet][:modules] = FalkorLib::Config::Puppet::Modules::DEFAULTS[:metadata]
        end
      end
      # Check the potential local customizations
      [:local, :private].each do |type|
        custom_cfg = File.join( res[:root], res[:config_files][type.to_sym])
        if File.exist?( custom_cfg )
          res.deep_merge!( load_config( custom_cfg ) )
        end
      end
      res
    end

    ###### get ######
    # Return the { local | private } FalkorLib configuration
    # Supported options:
    #  * :file [string] filename for the local configuration
    ##
    def get(dir = Dir.pwd, type = :local, options = {})
      conffile = config_file(dir, type, options)
      res = {}
      res = load_config( conffile ) if File.exist?( conffile )
      res
    end # get

    ###### get_or_save ######
    # wrapper for get and save operations
    ##
    def config_file(dir = Dir.pwd, type = :local, options = {})
      path = normalized_path(dir)
      path = FalkorLib::Git.rootdir(path) if FalkorLib::Git.init?(path)
      raise FalkorLib::Error, "Wrong FalkorLib configuration type" unless FalkorLib.config[:config_files].keys.include?( type.to_sym)
      (options[:file]) ? options[:file] : File.join(path, FalkorLib.config[:config_files][type.to_sym])
    end # get_or_save


    ###### save ######
    # save the { local | private } configuration on YAML format
    # Supported options:
    #  * :file [string] filename for the saved configuration
    #  * :no_interaction [boolean]: do not interact
    ##
    def save(dir = Dir.pwd, config = {}, type = :local, options = {})
      conffile = config_file(dir, type, options)
      confdir  = File.dirname( conffile )
      unless File.directory?( confdir )
        warning "about to create the configuration directory #{confdir}"
        really_continue?  unless options[:no_interaction]
        run %( mkdir -p #{confdir} )
      end
      store_config(conffile, config, options)
    end # save

  end

end # module FalkorLib
