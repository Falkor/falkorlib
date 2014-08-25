# -*- encoding: utf-8 -*-
################################################################################
# Time-stamp: <Lun 2014-08-25 21:34 svarrette>
################################################################################
# Interface for the main Puppet operations
#

require "falkorlib"
require "falkorlib/common"


include FalkorLib::Common

module FalkorLib  #:nodoc:
    module Config
	    module Puppet
		    # Puppet defaults for FalkorLib
		    DEFAULTS = {
			    :modulesdir => File.join(Dir.pwd, 'modules')
		    } 
	    end 
    end 

    module Puppet  #:nodoc
	    
    end



end 
