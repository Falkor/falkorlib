# -*- encoding: utf-8 -*-
################################################################################
# Time-stamp: <Ven 2014-06-06 19:20 svarrette>
################################################################################
# Management of Git Flow operations

require "falkorlib"
require "falkorlib/common"
require "falkorlib/git/base"

include FalkorLib::Common

module FalkorLib
    module Config

        # Default configuration for Gitflow
        module GitFlow
            # git flow defaults
            DEFAULTS = {
                :branches => {
                    :master     => 'production',
                    :develop    => 'master',
                },
                :prefix => {
                    :feature    => 'feature/',
                    :release    => 'release/',
                    :hotfix     => 'hotfix/',
                    :support    => 'support/',
                    :versiontag => "v",
                }
            }
        end
    end


    # Management of [git flow](https://github.com/nvie/gitflow) operations I'm
    # using everywhere
    module GitFlow

        module_function

        ## Initialize a git-flow repository
        def init(path = Dir.pwd)
            FalkorLib::Git.init(path)
            error "you shall install git-flow: see https://github.com/nvie/gitflow/wiki/Installation" unless command?('git-flow')
            remotes = FalkorLib::Git.remotes(path)

            if remotes.include?( 'origin' )
                info "=> configure remote (tracked) branches"
                FalkorLib.config.gitflow[:branches].each do |branch|
                    run %{
                      git fetch origin
                      git branch --set-upstream #{branch} origin/#{branch}
                    }
                end
            end

            info "=> initialize git flow configs"
            FalkorLib.config.gitflow[:branches].each do |t,branch|
		        execute "git config gitflow.branch.#{t} #{branch}"
            end
            FalkorLib.config.gitflow[:prefix].each do |t,prefix|
                execute "git config gitflow.prefix.#{t} #{prefix}"
            end
        end
    end











    # class GitFlow < ::Git::Base

    #     @@config = {
    #         :master     => 'production',
    #         :develop    => 'master',
    #         :feature    => 'feature/',
    #         :release    => 'release/',
    #         :hotfix     => 'hotfix/',
    #         :support    => 'support/',
    #         :versiontag => "v",
    #     }


    #     def initialize(base = nil, options = {})
    #         # @logger = options[:logger] || Logger.new(STDOUT)
    #         options.each do |k,v|
    #             self.config_set(k, v) if @@config.has_key?(k.to_sym)
    #         end
    #         #puts @@config.inspect
    #     end

    #     # def self.method_missing(sym, *args, &block)
    #     #     @@config[sym.to_s]
    #     # end

    #     def self.global_config(opt)
    #         @@config[opt.to_sym]
    #     end

    #     def self.config_set(opt, value)
    #         @@config[opt.to_sym] = value
    #     end

    #     # initializes a git flow repository
    #     # options:
    #     #  :repository
    #     #  :index_file
    #     #
    #     def self.init(working_dir, opts = {})
    #         super
    #         g = Git.open(working_dir)

    #         config = @@config
    #         @@config.keys.each do |k|
    #             config[k.to_sym] = opts[k.to_sym] if opts.has_key?(k.to_sym)
    #         end

    #         # Now update the local config for gitflow
    #         g.config('gitflow.branch.master',     config[:master])
    #         g.config('gitflow.branch.develop',    config[:develop])
    #         g.config('gitflow.prefix.feature',    config[:feature])
    #         g.config('gitflow.prefix.release',    config[:release])
    #         g.config('gitflow.prefix.hotfix',     config[:hotfix])
    #         g.config('gitflow.prefix.support',    config[:support])
    #         g.config('gitflow.prefix.versiontag', config[:versiontag])

    #         g.lib.send('command', 'flow init -d')
    #     end




    # end # End Falkorlib::GitFlow
end
