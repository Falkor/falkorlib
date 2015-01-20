# -*- encoding: utf-8 -*-
################################################################################
# Time-stamp: <Mar 2015-01-20 23:49 svarrette>
################################################################################
# Interface for the main Bootstrapping operations
#

require "falkorlib"
require "falkorlib/common"

include FalkorLib::Common

module FalkorLib
  module Bootstrap
    module_function
    
    ###
    # Initialize a trash directory in path
    ##
    def trash(path = Dir.pwd, dirname = FalkorLib.config[:templates][:trashdir], options = {})
      #args = method(__method__).parameters.map { |arg| arg[1].to_s }.map { |arg| { arg.to_sym => eval(arg) } }.reduce Hash.new, :merge
      #ap args
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
          FalkorLib::Git.add(File.join(path, dirname, '.gitignore' ), 'Add Trash directory',
                             { :force => true } )
        end
      end
    end # trash

    
  end # module Bootstrap
end # module FalkorLib

