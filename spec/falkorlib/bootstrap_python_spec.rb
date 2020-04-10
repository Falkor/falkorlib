#!/usr/bin/ruby
#########################################
# bootstrap_python_spec.rb
# @author Sebastien Varrette <Sebastien.Varrette@uni.lu>
# Time-stamp: <Fri 2020-04-10 23:52 svarrette>
#
# @description Check the Bootstrapping operations for python-based projects
#
# Copyright (c) 2013 Sebastien Varrette <Sebastien.Varrette@uni.lu>
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

  [ :without_git, :with_git ].each do |ctx|
    # [ :without_git ].each do |ctx|
    # [ :with_git ].each do |ctx|
    dir = dirs[ctx]
    ########################################################################
    context "bootstrap/python (#{ctx}) within temporary directory '#{dir}'" do

      if ctx == :with_git
        it "initialize Git in the temporary directory #{dir}" do
          c = FalkorLib::Git.init(dir)
          expect(c).to eq(0)
          t = FalkorLib::Git.init?(dir)
          expect(t).to be true
        end
      end

      ######### Pyenv/Direnv #########
      it "#pyenv -- #{ctx}" do
        c = FalkorLib::Bootstrap.pyenv(dir)
        expect(c).to eq(0)
        content = {}
        [:versionfile, :direnvfile].each do |type|
          f = File.join(dir, FalkorLib.config[:pyenv][type.to_sym])
          t = File.exists?(f)
          expect(t).to be true
          content[type.to_sym] = `cat #{f}`.chomp
        end
        expect(content[:versionfile]).to eq(FalkorLib.config[:pyenv][:version])
        #expect(content[:virtualenvfile]).to  eq(File.basename(dir))
        File.read(File.realpath( File.join(dir, FalkorLib.config[:pyenv][:direnvfile]))) do |f|
          [
            'layout virtualenv ${pyversion} ${pvenv}',
            'layout activate ${pvenv}'
          ].each do |pattern|
            f.should include "#{pattern}"
          end
        end
      end

      it "#python -- #{ctx} -- repeat" do
        t = FalkorLib::Bootstrap.pyenv(dir)
        expect(t).to eq(1)
        c = capture(:stdout) { FalkorLib::Bootstrap.pyenv(dir, { :force => true }) }
        [
          "The python/pyenv file '.python-version' already exists",
          "The python/pyenv file '.envrc' already exists",
          "and it WILL BE overwritten"
        ].each do |pattern|
          expect(c).to include pattern
        end
      end

      it "#pyenv -- change targets (ctx = #{ctx}; dir = #{dir})" do
        opts = {
          :python         => '3.7.1',
          :versionfile    => '.myversion',
          :virtualenv     => 'newvirtualenv',
          :virtualenvfile => '.myvirtualenv'
        }
        c = FalkorLib::Bootstrap.pyenv(dir, opts)
        expect(c).to eq(0)
        content = {}
        [:versionfile, :virtualenvfile].each do |type|
          f = File.join(dir, opts[type.to_sym])
          t = File.exists?(f)
          expect(t).to be true
          content[type.to_sym] = `cat #{f}`.chomp
        end
        expect(content[:versionfile]).to     eq(opts[:python])
        expect(content[:virtualenvfile]).to  eq(opts[:virtualenv])
      end



    end # context "bootstrap/python"
  end # each

end
