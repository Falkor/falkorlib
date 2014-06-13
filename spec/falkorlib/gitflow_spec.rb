#!/usr/bin/ruby
#########################################
# gitflow_spec.rb
# @author Sebastien Varrette <Sebastien.Varrette@uni.lu>
# Time-stamp: <Sam 2014-06-14 00:09 svarrette>
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
    
    dir   = Dir.mktmpdir
    afile = File.join(dir, 'a_file')

    after :all do
        FileUtils.remove_entry_secure dir
    end

    #############################################################
    context "Test git-flow operations within temporary directory " do

        it "#init? - fails on non-git directory" do
            t = FalkorLib::Git.init?(dir)
            t.should be_false
        end

        it "#init - initialize a git-flow repository" do
            STDIN.should_receive(:gets).and_return('Yes')
			i = FalkorLib::GitFlow.init(dir)
            i.should == 0
			t = FalkorLib::Git.init?(dir)
            t.should be_true
        end

	end 
end
