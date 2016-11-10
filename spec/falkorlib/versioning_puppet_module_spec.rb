#!/usr/bin/ruby
#########################################
# versioning_puppet_module_spec.rb
# @author Sebastien Varrette <Sebastien.Varrette@uni.lu>
# Time-stamp: <Thu 2016-11-10 02:04 svarrette>
#
# @description Check the versioning operations on Gems
#
# Copyright (c) 2013 Sebastien Varrette <Sebastien.Varrette@uni.lu>
# .             http://varrette.gforge.uni.lu
##############################################################################

require 'spec_helper'
require 'tmpdir'


describe FalkorLib::Versioning::Puppet do

  include FalkorLib::Common

  dir   = Dir.mktmpdir
  name      = 'toto'
  moduledir = File.join(dir, name)
  default_version  = FalkorLib.config[:versioning][:default]

  workingversion = {
    :default => '4.5.6',
    :patch   => '4.5.7',
    :minor   => '4.6.0',
    :major   => '5.0.0'
  }

  #_____________
  before :all do
    configatron.temp_start
    FalkorLib.config[:no_interaction] = true
    FalkorLib.config.versioning do |c|
      c[:type] = 'puppet_module'
    end
  end

  #_____________
  after :all do
    configatron.temp_end
    FileUtils.remove_entry_secure dir
    FalkorLib.config.versioning[:type] = 'file'
    FalkorLib.config[:no_interaction] = false
  end

  # configatron.temp do
  #     FalkorLib.config.versioning do |c|
  #         c[:type] = 'puppet_module'
  #     end

  ###################################################################
  context 'Test Puppet Module versioning operations within temporary directory' do

    ap default_version
    it "#get_version -- get default version #{default_version} after initialization" do
      #Array.new(17).each { |e|  expect(STDIN).to receive(:gets).and_return('') }
      FalkorLib::Puppet::Modules.init(moduledir)
      v = FalkorLib::Versioning.get_version(moduledir)
      expect(v).to eq(default_version)
      if command?('git-flow')
        a = FalkorLib::GitFlow.finish('feature', 'bootstrapping', moduledir)
        expect(a).to eq(0)
      end
    end

    it "#set_version -- should set the '#{workingversion[:default]}' version" do
      #expect(STDIN).to receive(:gets).and_return('Yes')
      v = FalkorLib::Versioning.set_version(workingversion[:default], moduledir)
      expect(v).to eq(0)
    end

    it "#get_version -- should get the '#{workingversion[:default]}'" do
      v = FalkorLib::Versioning.get_version(moduledir)
      expect(v).to eq(workingversion[:default])
    end

    it "#major -- should collect the major version" do
      v = FalkorLib::Versioning.get_version(moduledir)
      m = FalkorLib::Versioning.major(v)
      expect(m).to eq('4')
    end
    it "#minor -- should collect the minor version" do
      v = FalkorLib::Versioning.get_version(moduledir)
      m = FalkorLib::Versioning.minor(v)
      expect(m).to eq('5')
    end
    it "#patch -- should collect the patch version" do
      v = FalkorLib::Versioning.get_version(moduledir)
      m = FalkorLib::Versioning.patch(v)
      expect(m).to eq('6')
    end

    #FalkorLib.config[:versioning][:levels].reverse.each do |level|
    ['patch', 'minor'].each do |level|
      it "#set_version #bump -- #{level} bump version number from #{workingversion[:default]} to #{workingversion[level.to_sym]}" do
        v = FalkorLib::Versioning.get_version(moduledir)
        expect(v).to eq(workingversion[:default])
        v2 = FalkorLib::Versioning.bump(v, level.to_sym)
        expect(v2).to eq(workingversion[level.to_sym])
        #STDIN.should_receive(:gets).and_return('Yes')
        #d = FalkorLib::Versioning.set_version(v2, moduledir)
        #d.should == 0
        #v3 = FalkorLib::Versioning.get_version(moduledir)
        #v3.should == v2
      end
    end
  end

  #end #configatron.temp

end # describe FalkorLib::Versioning
