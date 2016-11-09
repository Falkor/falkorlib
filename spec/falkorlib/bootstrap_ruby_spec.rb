#!/usr/bin/ruby
#########################################
# bootstrap_ruby_spec.rb
# @author Sebastien Varrette <Sebastien.Varrette@uni.lu>
# Time-stamp: <Wed 2016-11-09 20:36 svarrette>
#
# @description Check the Bootstrapping operations for ruby-based projects
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
    context "bootstrap/ruby (#{ctx}) within temporary directory '#{dir}'" do

      if ctx == :with_git
        it "initialize Git in the temporary directory #{dir}" do
          c = FalkorLib::Git.init(dir)
          expect(c).to eq(0)
          t = FalkorLib::Git.init?(dir)
          expect(t).to be true
        end
      end

      ######### RVM #########
      it "#rvm -- #{ctx}" do
        c = FalkorLib::Bootstrap.rvm(dir)
        expect(c).to eq(0)
        content = {}
        [:versionfile, :gemsetfile].each do |type|
          f = File.join(dir, FalkorLib.config[:rvm][type.to_sym])
          t = File.exists?(f)
          expect(t).to be true
          content[type.to_sym] = `cat #{f}`.chomp
        end
        expect(content[:versionfile]).to eq(FalkorLib.config[:rvm][:version])
        expect(content[:gemsetfile]).to  eq(File.basename(dir))
        File.read(File.realpath( File.join(dir, 'Gemfile'))) do |f|
          [
            'https://rubygems.org',
            "gem 'falkorlib'"
          ].each do |pattern|
            f.should include "#{pattern}"
          end
        end
      end

      it "#rvm -- #{ctx} -- repeat" do
        t = FalkorLib::Bootstrap.rvm(dir)
        expect(t).to eq(1)
        c = capture(:stdout) { FalkorLib::Bootstrap.rvm(dir, { :force => true }) }
        [
          "The RVM file '.ruby-version' already exists",
          "The RVM file '.ruby-gemset' already exists",
          "and it WILL BE overwritten"
        ].each do |pattern|
          expect(c).to include pattern
        end

      end

      it "#rvm -- change targets (ctx = #{ctx}; dir = #{dir})" do
          opts = {
              :ruby        => '1.2.3',
              :versionfile => '.myversion',
              :gemset      => 'newgemset',
              :gemsetfile  => '.mygemset'
          }
          c = FalkorLib::Bootstrap.rvm(dir, opts)
          expect(c).to eq(0)
          content = {}
          [:versionfile, :gemsetfile].each do |type|
              f = File.join("#{dir}", opts[type.to_sym])
              t = File.exists?(f)
              content[type.to_sym] = `cat #{f}`.chomp
          end
          expect(content[:versionfile]).to eq(opts[:ruby])
          expect(content[:gemsetfile]).to  eq(opts[:gemset])
      end



    end # context "bootstrap/ruby"
  end # each

end
