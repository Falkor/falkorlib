#!/usr/bin/ruby
#########################################
# versioning_spec.rb
# @author Sebastien Varrette <Sebastien.Varrette@uni.lu>
# Time-stamp: <Sun 2016-10-16 22:12 svarrette>
#
# @description Check the versioning operations
#
# Copyright (c) 2013 Sebastien Varrette <Sebastien.Varrette@uni.lu>
# .             http://varrette.gforge.uni.lu
##############################################################################

require 'spec_helper'
require 'tmpdir'



describe FalkorLib::Versioning do

  include FalkorLib::Common

  dir   = Dir.mktmpdir

  workdir = File.join(dir, 'version')

  afile = File.join(workdir, 'a_file')
  versionfile     = FalkorLib.config[:versioning][:source]['file'][:filename]
  default_version = FalkorLib.config[:versioning][:default]
  workingversion = {
    :default => '1.2.3',
    :patch   => '1.2.4',
    :minor   => '1.3.0',
    :major   => '2.0.0'
  }

  before :all do
    FileUtils.mkdir_p workdir
    FalkorLib.config[:versioning][:type] = 'file'
  end

  after :all do
    FileUtils.remove_entry_secure dir
  end

  ###################################################################
  context 'Test versioning operations within temporary directory' do

    it "#get_version -- get default version #{default_version}" do
      if command?('git_flow')
        expect(STDIN).to receive(:gets).and_return('Yes')
        t = FalkorLib::GitFlow.init(workdir)
        expect(t).to eq(0)
      else
        t = FalkorLib::Git.init(workdir)
        expect(t).to be_truthy
      end
      v = FalkorLib::Versioning.get_version(workdir)
      expect(v).to eq(default_version)
    end

    it "#get_version -- should get the '#{workingversion[:default]}' version set in the file #{versionfile}" do
      execute "echo #{workingversion[:default]} > #{workdir}/#{versionfile}"
      v = FalkorLib::Versioning.get_version(workdir)
      expect(v).to eq(workingversion[:default])
    end

    it "#major -- should collect the major version" do
      v = FalkorLib::Versioning.get_version(workdir)
      m = FalkorLib::Versioning.major(v)
      expect(m).to eq('1')
    end
    it "#minor -- should collect the minor version" do
      v = FalkorLib::Versioning.get_version(workdir)
      m = FalkorLib::Versioning.minor(v)
      expect(m).to eq('2')
    end
    it "#patch -- should collect the patch version" do
      v = FalkorLib::Versioning.get_version(workdir)
      m = FalkorLib::Versioning.patch(v)
      expect(m).to eq('3')
    end


    it "#set_version -- set version #{default_version} in version file #{versionfile}" do
      expect(STDIN).to receive(:gets).and_return('no')
      v = FalkorLib::Versioning.set_version(default_version, workdir)
      expect(v).to eq(0)
      v = FalkorLib::Versioning.get_version(workdir)
      expect(v).to eq(default_version)
    end

    FalkorLib.config[:versioning][:levels].reverse.each do |level|
      it "#set_version #bump -- #{level} bump version number from #{workingversion[:default]} to #{workingversion[level.to_sym]}" do
        # restore version file
        execute "echo #{workingversion[:default]} > #{workdir}/#{versionfile}"
        v  = FalkorLib::Versioning.get_version(workdir)
        expect(v).to eq(workingversion[:default])
        v2 = FalkorLib::Versioning.bump(v, level.to_sym)
        expect(v2).to eq(workingversion[level.to_sym])
        expect(STDIN).to receive(:gets).and_return('no')
        d = FalkorLib::Versioning.set_version(v2, workdir)
        expect(d).to eq(0)
        v3 = FalkorLib::Versioning.get_version(workdir)
        expect(v3).to eq(v2)
      end
    end

  end
end
