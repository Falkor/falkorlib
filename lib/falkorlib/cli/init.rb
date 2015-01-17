# -*- encoding: utf-8 -*-
################################################################################
# Time-stamp: <Sam 2015-01-17 12:42 svarrette>
################################################################################

require 'thor'
require 'falkorlib'
require 'falkorlib/cli/runner'

module FalkorLib
  module CLI

    class Init < ::Thor
      # attr_reader :options

      # def initialize(options)
      #   @options = options
      # end

      # ###### run ######
      # def run

      # end # run

      ###### latex ######
      desc "latex [options]", "Bootstrap a LaTeX project"
      def latex
        ap desc
      end # Bootstrap a LaTeX project

      ###### repo ######
      desc "repo [options]", "Bootstrap a Git Repository"
      long_desc <<-REPO_LONG_DESC
Initiate a gir 
      REPO_LONG_DESC

      def repo
        info "tata"
      end
    end # class Init
  end # module CLI
end
