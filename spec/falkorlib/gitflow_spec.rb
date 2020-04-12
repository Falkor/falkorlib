#!/usr/bin/ruby
#########################################
# gitflow_spec.rb
# @author Sebastien Varrette <Sebastien.Varrette@uni.lu>
# Time-stamp: <Sun 2020-04-12 15:15 svarrette>
#
# @description Check the Git Flow operations -- see https://github.com/nvie/gitflow
#
# Copyright (c) 2013 Sebastien Varrette <Sebastien.Varrette@uni.lu>
# .             http://varrette.gforge.uni.lu
##############################################################################

require 'spec_helper'
require 'tmpdir'

describe FalkorLib::GitFlow do
  include FalkorLib::Common

  if command?('git-flow')


    dir   = Dir.mktmpdir
    afile = File.join(dir, 'a_file')

    after :all do
      FileUtils.remove_entry_secure dir
    end

    #############################################################
    context "Test git-flow operations within temporary directory " do

      it "#init? - fails on non-git directory" do
        t = FalkorLib::GitFlow.init?(dir)
        expect(t).to be false
      end

      it "#init - initialize a git-flow repository" do
        expect(STDIN).to receive(:gets).and_return('Yes')
        i = FalkorLib::GitFlow.init(dir)
        expect(i).to eq(0)
        t = FalkorLib::Git.init?(dir)
        expect(t).to be true
      end

      it "#init? - succeed on git-flow enabled directory" do
        t = FalkorLib::GitFlow.init?(dir)
        expect(t).to be true
      end

      it "#branch" do
        expected = {
          :master  => 'production',
          :develop => 'devel'
        }
        expected.each do |type,v|
          b = FalkorLib::GitFlow.branches(type.to_sym, dir)
          expect(b).to eq(expected[type.to_sym])
        end
      end


      #['feature', 'hotfix', 'support'].each do |op|
      ['feature'].each do |op|
        name = 'toto'
        it "#start -- should start a '#{op}' GitFlow operation" do
          a = FalkorLib::GitFlow.start(op, name, dir)
          expect(a).to eq(0)
          br = FalkorLib::Git.branch?( dir )
          expect(br).to eq("#{op}/#{name}")
        end

        it "#finish -- should finish a '#{op}' GitFlow operation" do
          expect(STDIN).to receive(:gets).and_return("Test #{op} operation") if [ 'hotfix', 'support' ].include?(op)
          a = FalkorLib::GitFlow.finish(op, name, dir)
          expect(a).to eq(0)
          br = FalkorLib::Git.branch?( dir )
          expect(br).to eq(FalkorLib.config[:gitflow][:branches][:develop])
        end
      end

      it "#guess_gitflow_config" do
        c = FalkorLib::GitFlow.guess_gitflow_config(dir)
        {
          :master  => 'production',
          :develop => 'devel'
        }.each do |type,v|
          expect(c[:branches][type.to_sym]).to eq(v)
        end
        {
          :feature    => 'feature/',
          :release    => 'release/',
          :hotfix     => 'hotfix/',
          :support    => 'support/',
          :versiontag => 'v'
        }.each do |type,v|
          expect(c[:prefix][type.to_sym]).to eq(v)
        end
      end

    end

  end
end
