#!/usr/bin/ruby
#########################################
# bootstrap_vagrant_spec.rb
# @author Sebastien Varrette <Sebastien.Varrette@uni.lu>
# Time-stamp: <Sun 2020-04-12 14:22 svarrette>
#
# @description Check the Bootstrapping operations for Vagrant
#
# Copyright (c) 2020 Sebastien Varrette <Sebastien.Varrette@uni.lu>
# .             http://varrette.gforge.uni.lu
##############################################################################

require 'spec_helper'
require 'tmpdir'
require 'fileutils'

describe FalkorLib::Bootstrap do

  include FalkorLib::Common

  dirs = {
    :without_git => Dir.mktmpdir,
    :with_git    => Dir.mktmpdir,
  }

  #_____________
  before :all do
    $stdout.sync = true
    FalkorLib.config[:no_interaction] = true
  end

  #____________
  after :all do
    dirs.each do |t,d|
      #next if t == :with_git
      FileUtils.remove_entry_secure d
    end
    FalkorLib.config[:no_interaction] = false
  end

  #[ :without_git, :with_git ].each do |ctx|
    # [ :without_git ].each do |ctx|
    [ :with_git ].each do |ctx|
    dir = dirs[ctx]
    ########################################################################
    context "bootstrap/vagrant (#{ctx}) within temporary directory '#{dir}'" do

      if ctx == :with_git
        it "initialize Git in the temporary directory #{dir}" do
          c = FalkorLib::Git.init(dir)
          expect(c).to eq(0)
          t = FalkorLib::Git.init?(dir)
          expect(t).to be true
        end
      end

      ######### vagrant #########
      it "#vagrant -- #{ctx}" do
        c = FalkorLib::Bootstrap.vagrant(dir)
        expect(c).to eq(0)
        confdir = File.join(dir, 'vagrant')
        conffile = File.join(dir, 'Vagrantfile')
        expect(File.directory?(confdir)).to be true
        expect(File.exists?(conffile)).to be true
        bootstrap = File.join(confdir, 'bootstrap.sh')
        expect(File.exists?(bootstrap)).to be true

        # File.read(File.realpath(conffile)) do |f|
        #   [
        #     "site_name: #{File.basename(dir)}",
        #     "nav:"
        #   ].each do |pattern|
        #     f.should include "#{pattern}"
        #   end
        # end
      end

    end # context "bootstrap/mkdocs"
  end # each

end
