# -*- encoding: utf-8 -*-
# Time-stamp: <Mar 2014-06-03 23:40 svarrette>
#
# FalkorLib Configuration
# Resources:
#  * https://github.com/markbates/cover_me/blob/master/lib/cover_me/config.rb
################################################################################
require "falkorlib"

require "configatron"
require "configatron/store"

module FalkorLib

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

        # def test_config
        #     $".each do |path|
        #         next unless path.include?('falkorlib/git.rb')
        #         puts path
        #     end
        # end

    end

    module Config
        DEFAULTS = {
            :debug => false,
            :root  => Dir.pwd
        }

        module_function

        ## Build the default configuration hash, to be used to initiate the default  
        def default
            res = FalkorLib::Config::DEFAULTS
	        $LOADED_FEATURES.each do |path| 
		        res[:gitflow] = FalkorLib::Config::GitFlow::DEFAULTS if path.include?('lib/falkorlib/git.rb')
	        end 
	        res
        end

    end

    # config = Thread.current[:config] ||= Configatron::Store.new

    # # Singleton configuration class
    # class Config
    #     include Singleton

    #     # Give memoized defaults for locked configuration options found in /config/falkorlib.yml file
    #     #
    #     # @example Usage
    #     #   conf = Configuration.instance.defaults
    #     #   conf.base_url       #=> "http://ambito.com/economia/mercados/monedas/dolar/"
    #     #   conf.blue.buy.xpath #=> "//*[@id=\"contenido\"]/div[1]/div[2]/div/div/div[2]/big"
    #     #
    #     # @return [Configatron::Store] the magic configuration instance with hash and dot '.' indifferent access
    #     def defaults
    #       return @config if @config

    #       @config = Configatron::Store.new
    #       file_path   = File.expand_path('../../../config/falkorlib.yml', __FILE__)
    #       hash_config = YAML::load_file(file_path)

    #       @config.configure_from_hash(hash_config)
    #       @config.lock!
    #       @config
    #     end
    # end


end # module FalkorLib
