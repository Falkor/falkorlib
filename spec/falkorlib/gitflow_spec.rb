#!/usr/bin/ruby
#########################################
# gitflow_spec.rb
# @author Sebastien Varrette <Sebastien.Varrette@uni.lu>
# Time-stamp: <Jeu 2015-01-22 15:52 svarrette>
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
                t.should be_false
            end	

            it "#init - initialize a git-flow repository" do
                STDIN.should_receive(:gets).and_return('Yes')
                i = FalkorLib::GitFlow.init(dir)
                i.should == 0
                t = FalkorLib::Git.init?(dir)
                t.should be_true
            end

            it "#init? - succeed on git-flow enabled directory" do
                t = FalkorLib::GitFlow.init?(dir)
                t.should be_true
            end	

            #['feature', 'hotfix', 'support'].each do |op|
            ['feature'].each do |op|
                name = 'toto'
                it "#start -- should start a '#{op}' GitFlow operation" do
                    a = FalkorLib::GitFlow.start(op, name, dir)
                    a.should == 0
                    br = FalkorLib::Git.branch?( dir )
                    br.should == "#{op}/#{name}"
                end

                it "#finish -- should finish a '#{op}' GitFlow operation" do
                    STDIN.should_receive(:gets).and_return("Test #{op} operation") if [ 'hotfix', 'support' ].include?(op)
                    a = FalkorLib::GitFlow.finish(op, name, dir)
                    a.should == 0
                    br = FalkorLib::Git.branch?( dir )
                    br.should == FalkorLib.config[:gitflow][:branches][:develop]
                end
            end
        end

    end
end
