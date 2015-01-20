# -*- encoding: utf-8 -*-
################################################################################
# Time-stamp: <Mar 2015-01-20 10:12 svarrette>
################################################################################
# Interface for the bootstrapping of a new Git repository
#

require "falkorlib"
require "falkorlib/common"
require "falkorlib/git"

include FalkorLib::Common


module FalkorLib  #:nodoc:
  module Config
    module Templates
      module Repo
        DEFAULTS = {
          :type        => 'latex',
          :use_gitflow => true,
          :use_make    => true,
          :submodules  => {
            'gitstats' => { :url => 'https://github.com/hoxu/gitstats.git' }
          }
          :gitflow     => FalkorLib.config.gitflow
        }
      end # module Repository
    end
  end
end


