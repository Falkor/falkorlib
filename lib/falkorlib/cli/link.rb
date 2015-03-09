# -*- encoding: utf-8 -*-
################################################################################
# Time-stamp: <Lun 2015-03-09 12:03 svarrette>
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
                raise FalkorLib::ExecError "Not used in a Git repository" unless FalkorLib::Git.init?
                path  = normalized_path(dir)
                relative_path_to_root = Pathname.new( FalkorLib::Git.rootdir(dir) ).relative_path_from Pathname.new( File.realpath(path))
                FalkorLib::Common.error "Already at the root directory of the Git repository" if "#{relative_path_to_root}" == "."
                target = options[:name] ? options[:name] : '.root'
                unless File.exists?( File.join(path, target))
                    warning "creating the symboling link '#{target}' which points to '#{relative_path_to_root}'" if options[:verbose]
                    # Format: ln_s(old, new, options = {}) -- Creates a symbolic link new which points to old.
                     FileUtils.ln_s "#{relative_path_to_root}", "#{target}"
                end
            end # rootdir

            



        end # class Link
    end # module CLI
end # module FalkorLib
