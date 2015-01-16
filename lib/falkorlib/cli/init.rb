# -*- encoding: utf-8 -*-
################################################################################
# Time-stamp: <Ven 2015-01-16 11:47 svarrette>
################################################################################

require 'thor'
require 'falkorlib'
require 'falkorlib/cli/runner'

module FalkorLib
  module CLI

    include FalkorLib::Common

    class Init < ::Thor
      #namespace :init   #bootstrap

      ###### latex ######
      desc "latex [options]", "Bootstrap a LaTeX project"
      def latex
        info "toto"
      end # Bootstrap a LaTeX project

      ###### repo ######
      desc "repo [options]", "Bootstrap a Git Repository"
      def repo
        info "tata"
      end

    end # class Init
  end # module CLI
end
