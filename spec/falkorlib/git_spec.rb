#!/usr/bin/ruby
#########################################
# git_spec.rb
# @author Sebastien Varrette <Sebastien.Varrette@uni.lu>
# Time-stamp: <Mer 2014-06-04 16:59 svarrette>
#
# @description Check the Git operation 
#
# Copyright (c) 2013 Sebastien Varrette <Sebastien.Varrette@uni.lu>
# .             http://varrette.gforge.uni.lu
##############################################################################

require 'spec_helper'
require 'tmpdir'

describe FalkorLib::Git do

	default_branches = [ 'devel', 'production' ] 
    
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
