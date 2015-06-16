# -*- encoding: utf-8 -*-
################################################################################
# Time-stamp: <Mon 2015-06-15 18:15 svarrette>
################################################################################

require 'thor'
require 'falkorlib'
#require 'falkorlib/cli/init/repo'
#require "falkorlib/bootstrap"

module FalkorLib
    module CLI

        # Thor class for symlink creation
        class Link < ::Thor

            include FalkorLib::Common

            ###### rootdir (root beeing reserved) ######
            method_option :name, :aliases => ['--target', '-t', '-n'], :default => '.root', :desc => "Name of the symlink"
            #......................................
            desc "rootdir [options]", "Create a symlink '.root' which targets the root of the repository"
            def rootdir(dir = Dir.pwd)
                FalkorLib::Bootstrap.rootlink(dir, options)
            end # rootdir



        end # class Link
    end # module CLI
end # module FalkorLib
