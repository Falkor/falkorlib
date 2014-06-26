#!/usr/bin/ruby
#########################################
# gitflow_spec.rb
# @author Sebastien Varrette <Sebastien.Varrette@uni.lu>
# Time-stamp: <Jeu 2014-06-26 23:23 svarrette>
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
			if command?('git_flow')
				STDIN.should_receive(:gets).and_return('Yes') 
				t = FalkorLib::GitFlow.init(dir)
				t.should == 0
			else 
				t = FalkorLib::Git.init(dir)
				t.should be_true 
			end 
			v = FalkorLib::Versioning.get_version(dir)
            v.should == default_version
        end

        it "#get_version -- should get the '#{workingversion[:default]}' version set in the file #{versionfile}" do
            execute "echo #{workingversion[:default]} > #{dir}/#{versionfile}"
            v = FalkorLib::Versioning.get_version(dir)
            v.should == workingversion[:default]
        end

		it "#major -- should collect the major version" do
			v = FalkorLib::Versioning.get_version(dir)
			m = FalkorLib::Versioning.major(v)
			m.should == '1'
		end
		it "#minor -- should collect the minor version" do
			v = FalkorLib::Versioning.get_version(dir)
			m = FalkorLib::Versioning.minor(v)
			m.should == '2'
		end
		it "#patch -- should collect the patch version" do
			v = FalkorLib::Versioning.get_version(dir)
			m = FalkorLib::Versioning.patch(v)
			m.should == '3'
		end


        it "#set_version -- set version #{default_version} in version file #{versionfile}" do
            STDIN.should_receive(:gets).and_return('no')
            v = FalkorLib::Versioning.set_version(default_version, dir)
            v.should == 0
            v = FalkorLib::Versioning.get_version(dir)
            v.should == default_version
        end

        FalkorLib.config[:versioning][:levels].reverse.each do |level|
            it "#set_version #bump -- #{level} bump version number from #{workingversion[:default]} to #{workingversion[level.to_sym]}" do
                # restore version file
                execute "echo #{workingversion[:default]} > #{dir}/#{versionfile}"
                v  = FalkorLib::Versioning.get_version(dir)
                v.should == workingversion[:default]
                v2 = FalkorLib::Versioning.bump(v, level.to_sym)
                v2.should == workingversion[level.to_sym]
                STDIN.should_receive(:gets).and_return('no')
                d = FalkorLib::Versioning.set_version(v2, dir)
                d.should == 0
                v3 = FalkorLib::Versioning.get_version(dir)
                v3.should == v2
            end
        end

        # it "should do something" do

        # end


        # it "#set_version --  restore versionfile and add it to git" do
        #     STDIN.should_receive(:gets).and_return('Yes')
        #     t =  FalkorLib::Versioning.set_version(workingversion[:default], dir)
        #     t.should == 0
        # end

        # FalkorLib.config[:versioning][:levels].reverse.each do |level|
        #     it "#set_version #bump -- #{level} bump version number from #{workingversion[:default]} to #{workingversion[level.to_sym]} with git commit" do
		# 		if FalkorLib::Versioning.get_version(dir) != workingversion[:default]
		# 			STDIN.should_receive(:gets).and_return('Yes')
		# 			t =  FalkorLib::Versioning.set_version(workingversion[:default], dir)
		# 			t.should == 0
		# 		end 
		# 		v  = FalkorLib::Versioning.get_version(dir)
        #         v.should == workingversion[:default]
        #         v2 = FalkorLib::Versioning.bump(v, level.to_sym)
        #         v2.should == workingversion[level.to_sym]
		# 		STDIN.should_receive(:gets).and_return('Yes')
        #         d = FalkorLib::Versioning.set_version(v2, dir)
        #         d.should == 0
        #         v3 = FalkorLib::Versioning.get_version(dir)
        #         v3.should == v2
        #     end
        # end

    end
end
