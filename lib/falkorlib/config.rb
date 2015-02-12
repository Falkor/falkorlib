# -*- encoding: utf-8 -*-
################################################################################
# Time-stamp: <Jeu 2015-02-12 11:07 svarrette>
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
        def config(&block)
            yield configuration if block_given?
            configuration
        end

        ## initiate the configuration (with default value) if needed
        def configuration
            @config ||= Configatron::Store.new(options = FalkorLib::Config.default)
        end
    end


    module Config #:nodoc:
        # Defaults global settings
        DEFAULTS = {
                    :debug        => false,
                    :verbose      => false,
                    :root         => Dir.pwd,
                    :config_files => {
                                      :local   => '.falkor/config',
                                      :private => '.falkor/private',
                                      #:project => '.falkor/project',
                                     },
                    #:custom_cfg   => '.falkorlib.yaml',
                    :rvm => {
                             :rubies      => [ '1.9.3', '2.0.0', '2.1.0'],
                             :version     => '1.9.3',
                             :versionfile => '.ruby-version',
                             :gemsetfile  => '.ruby-gemset'
                            },
                    :templates => {
                                   :trashdir => '.Trash',
                                   :puppet   => {}
                                  },
                    :tokens  => { :code_climate => '' },
                    :project => {}
                   }

        module_function

        ## Build the default configuration hash, to be used to initiate the default.
        # The hash is built depending on the loaded files.
        def default
            res = FalkorLib::Config::DEFAULTS
            $LOADED_FEATURES.each do |path|
                res[:git]        = FalkorLib::Config::Git::DEFAULTS        if path.include?('lib/falkorlib/git.rb')
                res[:gitflow]    = FalkorLib::Config::GitFlow::DEFAULTS    if path.include?('lib/falkorlib/git.rb')
                res[:versioning] = FalkorLib::Config::Versioning::DEFAULTS if path.include?('lib/falkorlib/versioning.rb')
                if path.include?('lib/falkorlib/puppet.rb')
                    res[:puppet]     = FalkorLib::Config::Puppet::DEFAULTS
                    res[:templates][:puppet][:modules] = FalkorLib::Config::Puppet::Modules::DEFAULTS[:metadata]
                end
            end
            # Check the potential local customizations
            [:local, :private].each do |type|
                custom_cfg = File.join( res[:root], res[:config_files][type.to_sym])
                if File.exists?( custom_cfg )
                    res.deep_merge!( load_config( custom_cfg ) )
                end
            end
            res
        end

        ###### load_project ######
        # Return the local project configuration
        ##
        def load_project(dir = Dir.pwd, options = {})
            project_file = options[:file] ? options[:file] : FalkorLib.config[:config_files][:local]
            path = normalized_path(dir)
            path = FalkorLib::Git.rootdir(path) if FalkorLib::Git.init?(path)
            res = {}
            #if File.exists?( )
        end # load_project


    end



end # module FalkorLib
