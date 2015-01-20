# -*- encoding: utf-8 -*-
################################################################################
# Time-stamp: <Mar 2015-01-20 23:15 svarrette>
################################################################################
# Interface for the main Bootstrapping operations
#

require "falkorlib"
require "falkorlib/common"

include FalkorLib::Common

module FalkorLib
  module Bootstrap

    ###
    # Initialize a trash directory in path
    ##
    def trash(path = Dir.pwd, dirname = FalkorLib.config[:templates][:trashdir], options = {})
      if Dir.exists?(dirname)
        warning "The trash directory '#{dirname}' already exists"
        return
      end
      Dir.chdir(path) do
        info "creating the trash directory '#{dirname}'"
        run %{
          mkdir #{dirname}
          echo '*' > #{dirname}/.gitignore
        }
        if FalkorLib::Git.init?
          FalkorLib::Git.add(File.join(dirname, '.gitignore' ), 'Add Trash directory')
        end
      end
    end # trash
    
  end # module Bootstrap
end # module FalkorLib

