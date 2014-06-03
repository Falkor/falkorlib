require 'falkorlib/common'
require 'git'

module FalkorLib

    class GitFlow < ::Git::Base

        @@config = {
            :master     => 'production',
            :develop    => 'master',
            :feature    => 'feature/',
            :release    => 'release/',
            :hotfix     => 'hotfix/',
            :support    => 'support/',
            :versiontag => "v",
        }


        def initialize(base = nil, options = {})
            # @logger = options[:logger] || Logger.new(STDOUT)
            options.each do |k,v|
                self.config_set(k, v) if @@config.has_key?(k.to_sym)
            end
            #puts @@config.inspect
        end

        # def self.method_missing(sym, *args, &block)
        #     @@config[sym.to_s]
        # end

        def self.global_config(opt)
            @@config[opt.to_sym]
        end

        def self.config_set(opt, value)
            @@config[opt.to_sym] = value
        end

        # initializes a git flow repository
        # options:
        #  :repository
        #  :index_file
        #
        def self.init(working_dir, opts = {})
	        super
	        g = Git.open(working_dir)

	        config = @@config
	        @@config.keys.each do |k| 
		        config[k.to_sym] = opts[k.to_sym] if opts.has_key?(k.to_sym)
	        end

            # Now update the local config for gitflow
            g.config('gitflow.branch.master',     config[:master])
            g.config('gitflow.branch.develop',    config[:develop])
            g.config('gitflow.prefix.feature',    config[:feature])
            g.config('gitflow.prefix.release',    config[:release])
            g.config('gitflow.prefix.hotfix',     config[:hotfix])
            g.config('gitflow.prefix.support',    config[:support])
            g.config('gitflow.prefix.versiontag', config[:versiontag])

	        g.lib.send('command', 'flow init -d')
        end




    end # End Falkorlib::GitFlow
end
