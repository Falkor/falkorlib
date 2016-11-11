# -*- encoding: utf-8 -*-
################################################################################
# Time-stamp: <Fri 2016-11-11 15:13 svarrette>
################################################################################
# Interface for the main Puppet operations
#

require "falkorlib"
require "falkorlib/common"


include FalkorLib::Common

module FalkorLib #:nodoc:

  module Config
    module Puppet

      # Puppet defaults for FalkorLib
      DEFAULTS = {
        :modulesdir => File.join(Dir.pwd, 'modules')
      }

    end
  end

  module Puppet #:nodoc

  end



end
