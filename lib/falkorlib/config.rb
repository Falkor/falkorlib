# -*- encoding: utf-8 -*-
# Time-stamp: <Mar 2014-06-03 16:11 svarrette>
#
# FalkorLib Configuration
################################################################################
require "falkorlib"

require "configatron/core"
require 'singleton'        # stdlib
require 'yaml'             # stdlib


module FalkorLib

	config = Thread.current[:config] ||= Configatron::Store.new

	module Config

		def print
			ap config.to_h
		end
		
	end



    # def self.config
    #     Thread.current[:config] ||= Config.new
    # end

    # def self.debug=(bool) 
	#     FalkorLib.config.debug = bool
    # end 

    # def self.debug
	#     FalkorLib.config.debug.nil? ? false : FalkorLib.config.debug
    # end 

    # # Singleton configuration class
    # class Config
	#     include Singleton

	#     # Give memoized defaults for locked configuration options found in /config/xpaths.yml file
	#     #
	#     # @example Usage
	#     #   conf = Configuration.instance.defaults
	#     #   conf.base_url       #=> "http://ambito.com/economia/mercados/monedas/dolar/"
	#     #   conf.blue.buy.xpath #=> "//*[@id=\"contenido\"]/div[1]/div[2]/div/div/div[2]/big"
	#     #
	#     # @return [Configatron::Store] the magic configuration instance with hash and dot '.' indifferent access
	#     def defaults
	# 	    return @config if @config

	# 	    @config = Configatron::Store.new
	# 	    file_path   = File.expand_path('../../../config/falkorlib.yml', __FILE__)
	# 	    hash_config = YAML::load_file(file_path)

	# 	    @config.configure_from_hash(hash_config)
	# 	    @config.lock!
	# 	    @config
	#     end
    # end



    # # # See https://github.com/markbates/configatron#kernel
    # # class Config << ::Configatron::Store
    
    # def print
	#     ap @config.to_h
    # end

    # # end


end # module FalkorLib
