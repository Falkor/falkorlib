# -*- encoding: utf-8 -*-
################################################################################
# Time-stamp: <Mon 2020-04-20 17:52 svarrette>
################################################################################
# Interface for Bootstrapping MkDocs
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

    ###### mkdocs ######
    # Initialize MkDocs in the current directory
    # Supported options:
    #  * :force       [boolean] force overwritting
    ##
    def mkdocs(dir = Dir.pwd, options = {})
      info "Initialize MkDocs (see http://www.mkdocs.org/)"
      path = normalized_path(dir)
      use_git = FalkorLib::Git.init?(path)
      rootdir = (use_git) ? FalkorLib::Git.rootdir(path) : path
      templatedir = File.join( FalkorLib.templates, 'mkdocs')
      config = guess_project_config(rootdir, options)
      config[:rootdir]  = rootdir
      config[:sitename] = ask("\tSite name: ", config[:name])
      #FalkorLib::GitFlow.start('feature', 'mkdocs', rootdir) if (use_git && FalkorLib::GitFlow.init?(rootdir))
      init_from_template(templatedir, rootdir, config,
                         :no_interaction => true,
                         :no_commit => true)
      Dir.chdir( File.join(rootdir, 'docs')) do
        run %(ln -s README.md index.md )
        run %(ln -s README.md contributing/index.md )
      end
      #exit_status.to_i
    end # mkdocs

  end # module Bootstrap
end # module FalkorLib
