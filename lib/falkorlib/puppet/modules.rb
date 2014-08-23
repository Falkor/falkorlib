# -*- encoding: utf-8 -*-
################################################################################
# Time-stamp: <Sam 2014-08-23 18:54 svarrette>
################################################################################
# Interface for the main Puppet Module operations
#

require "falkorlib"
require "falkorlib/common"

require "pathname"

include FalkorLib::Common

module FalkorLib  #:nodoc:
    module Config
        module Puppet
            module Modules
                DEFAULTS = {
                    :metadata => {
                        :name         => '',
                        :version      => '0.0.1',
                        :author       => "#{ENV['GIT_AUTHOR_NAME']}"
                        :summary      => '',
			            :description  => '',
                        :license      => 'GPLv3',
                        :source       => '',
                        :project_page => '',
                        :issue_url    => '',
                        :dependencies => [],
                        :operatingsystem_support => [],
                        :tags         => []
                    }
                end
            end
        end
    end

    # Puppet actions
    module Puppet
        # Management of Puppet Modules operations
        module Modules
            module_function


        end # module FalkorLib::Puppet::Modules
    end # module FalkorLib::Puppet
end # module FalkorLib
