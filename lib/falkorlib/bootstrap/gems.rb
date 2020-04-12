# -*- encoding: utf-8 -*-
################################################################################
# Time-stamp: <Mon 2017-01-16 10:14 svarrette>
################################################################################
# Interface for Bootstrapping a Ruby gem
#

require "falkorlib"
require "falkorlib/common"
require "falkorlib/bootstrap"

include FalkorLib::Common

module FalkorLib
  module Bootstrap #:nodoc:

    module_function

    ###### gem ######
    # Initialize a Ruby gem project
    # Supported options:
    #  * :force [boolean] force action
    ##
    def gem(dir = Dir.pwd, options = {})
      info "Initialize a Ruby gem "

    end # gem



  end # module Bootstrap
end # module FalkorLib
