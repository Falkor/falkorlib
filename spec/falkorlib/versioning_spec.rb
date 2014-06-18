#!/usr/bin/ruby
#########################################
# gitflow_spec.rb
# @author Sebastien Varrette <Sebastien.Varrette@uni.lu>
# Time-stamp: <Mer 2014-06-18 21:02 svarrette>
#
# @description Check the Git Flow operations -- see https://github.com/nvie/gitflow
#
# Copyright (c) 2013 Sebastien Varrette <Sebastien.Varrette@uni.lu>
# .             http://varrette.gforge.uni.lu
##############################################################################

require 'spec_helper'
require 'tmpdir'

describe FalkorLib::Versioning do

    include FalkorLib::Common

    dir   = Dir.mktmpdir
    afile = File.join(dir, 'a_file')
    versionfile     = FalkorLib.config[:versioning][:source]['file'][:filename]
    default_version = FalkorLib.config[:versioning][:default]
	workingversion = {
		:default => '1.2.3',
		:patch   => '1.2.4',
		:minor   => '1.3.0',
		:major   => '2.0.0'
 	} 

    after :all do
        FileUtils.remove_entry_secure dir
    end


    ###################################################################
    context 'Test versioning operations within temporary directory' do

        it "#get_version -- get default version #{default_version}" do
            STDIN.should_receive(:gets).and_return('Yes')
            i = FalkorLib::GitFlow.init(dir)
            i.should == 0
            v = FalkorLib::Versioning.get_version(dir)
            v.should == default_version
        end

		it "#get_version -- should get the '#{workingversion[:default]}' version set in the file #{versionfile}" do
			execute "echo #{workingversion[:default]} > #{dir}/#{versionfile}"
			v = FalkorLib::Versioning.get_version(dir)
			v.should == workingversion[:default]
		end

		FalkorLib.config[:versioning][:levels].reverse.each do |level| 
			it "#bump -- #{level} bump version number from #{workingversion[:default]} to #{workingversion[level.to_sym]}" do
				v  = FalkorLib::Versioning.get_version(dir)
				v2 = FalkorLib::Versioning.bump(v, level.to_sym)
				v2.should == workingversion[level.to_sym]
				#v.should == fileversion
			end
		end


		


    end



end
