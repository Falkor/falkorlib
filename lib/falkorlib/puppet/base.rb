# -*- encoding: utf-8 -*-
################################################################################
# Time-stamp: <Lun 2014-08-25 21:05 svarrette>
################################################################################
# Interface for the main Puppet operations
#

require "falkorlib"
require "falkorlib/common"


include FalkorLib::Common

module FalkorLib  #:nodoc:
    module Config

        # Default configuration for Puppet
        module Puppet
            # Puppet defaults for FalkorLib
            DEFAULTS = {
                :modulesdir => File.join(Dir.pwd, 'modules')
            }
        end
    end
end 
