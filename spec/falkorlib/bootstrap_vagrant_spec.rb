#!/usr/bin/ruby
#########################################
# bootstrap_vagrant_spec.rb
# @author Sebastien Varrette <Sebastien.Varrette@uni.lu>
# Time-stamp: <Mon 2020-04-20 10:10 svarrette>
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
        conffile = File.join(dir, 'Vagrantfile')
        expect(File.exists?(conffile)).to be true
        confdir      = File.join(dir, 'vagrant')
        puppetdir    = File.join(confdir, 'puppet')
        scriptsdir   = File.join(confdir, 'scripts')
        [ confdir, puppetdir, scriptsdir ].each do |d|
          expect(File.directory?(d)).to be true
        end
        bootstrap = File.join(scriptsdir, 'bootstrap.sh')
        expect(File.exists?(bootstrap)).to be true
        hiera_config = File.join(puppetdir, 'hiera.yaml')
        expect(File.exists?(hiera_config)).to be true
        [ 'hieradata', 'manifests', 'modules', 'site/profiles' ].each do |d|
          expect(File.directory?(File.join(puppetdir, d))).to be true
        end
      end

    end # context "bootstrap/vagrant"
  end # each

end
