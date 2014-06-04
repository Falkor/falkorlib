#!/usr/bin/ruby
#########################################
# git_spec.rb
# @author Sebastien Varrette <Sebastien.Varrette@uni.lu>
# Time-stamp: <Mer 2014-06-04 22:55 svarrette>
#
# @description Check the Git operation
#
# Copyright (c) 2013 Sebastien Varrette <Sebastien.Varrette@uni.lu>
# .             http://varrette.gforge.uni.lu
##############################################################################

require 'spec_helper'
require 'tmpdir'

describe FalkorLib::Git do

    include FalkorLib::Common
    default_branches = [ 'devel', 'production' ]
	
	dir = Dir.mktmpdir

    before :all do
		puts "temp dir : #{dir}"
    end
	after :all do 
		FileUtils.remove_entry_secure dir
	end 

    #######################
    context 'Test git init' do

        it "fails on non-git directory #{dir}" do
            #expect { FalkorLib::Git.init?(dir) }.to raise_error 
			t = FalkorLib::Git.init?(dir)
            t.should be_false
        end

        it "initialize a git repository #{dir}" do
			FalkorLib::Git.init(dir)
            #res = capture(:stdout) { FalkorLib::Git.init(dir) } #(dir) }
            #puts res
            b = FalkorLib::Git.init?(dir)
            b.should be_true
        end

		


    end


    #############################################
    context "Test git branch functions" do
        it "should return the current branch (#{default_branches[0]})" do
            br = FalkorLib::Git.branch?
            br.should == "#{default_branches[0]}"
        end
        it "should list default branches (#{default_branches.join(',')})" do
            a = FalkorLib::Git.get_branches
            default_branches.each do |br|
                a.should include(br)
            end
        end
    end




end
