#!/usr/bin/ruby
#########################################
# versioning_gem_spec.rb
# @author Sebastien Varrette <Sebastien.Varrette@uni.lu>
# Time-stamp: <Mar 2014-07-01 17:29 svarrette>
#
# @description Check the versioning operations on Gems
#
# Copyright (c) 2013 Sebastien Varrette <Sebastien.Varrette@uni.lu>
# .             http://varrette.gforge.uni.lu
##############################################################################

require 'spec_helper'
require 'tmpdir'


describe FalkorLib::Versioning do

    include FalkorLib::Common

    dir   = Dir.mktmpdir
    versionfile      = 'spec_gem_version.rb'
    versionfile_path = File.join(dir, versionfile)
    default_version  = FalkorLib.config[:versioning][:default]

    workingversion = {
        :default => '4.5.6',
        :patch   => '4.5.7',
        :minor   => '4.6.0',
        :major   => '5.0.0'
    }

    after :all do
        FileUtils.remove_entry_secure dir
		configatron.temp do
			FalkorLib.config.versioning[:type] = 'file'
		end 
    end

    configatron.temp do
        FalkorLib.config.versioning do |c|
            c[:type] = 'gem'
            c[:source]['gem'][:filename]  = "#{versionfile}"
            c[:source]['gem'][:getmethod] = "::TestGemVersion.version"
        end


        ###################################################################
        context 'Test GEM versioning operations within temporary directory' do
            it "#get_version -- NameError on non-existing method" do
				if command?('git_flow')
                    STDIN.should_receive(:gets).and_return('Yes')
                    t = FalkorLib::GitFlow.init(dir)
                    t.should == 0
                else
                    t = FalkorLib::Git.init(dir)
                    t.should be_true
                end
                expect { FalkorLib::Versioning.get_version(dir) }.to raise_error (NameError)
            end

            File.open(versionfile_path, 'w') do |f|
                f.puts "module TestGemVersion"
                f.puts "   MAJOR, MINOR, PATCH = 4, 5, 6"
                f.puts "   module_function"
                f.puts "   def version"
                f.puts "      [ MAJOR, MINOR, PATCH ].join('.')"
                f.puts "   end"
                f.puts "end"
            end

            it "initializes the Gem version file #{versionfile} " do
                t = File.exists?(versionfile_path)
                t.should be_true
                u = run %{ cat #{versionfile_path} }
                u.to_i.should == 0
            end

            it "#get_version -- should get the '#{workingversion[:default]}' version set in the file #{versionfile}" do
                load "#{versionfile_path}"
                v = FalkorLib::Versioning.get_version(dir)
                v.should == workingversion[:default]
            end

            it "#major -- should collect the Gem major version" do
                v = FalkorLib::Versioning.get_version(dir)
                m = FalkorLib::Versioning.major(v)
                m.should == '4'
            end
            it "#minor -- should collect the Gem minor version" do
                v = FalkorLib::Versioning.get_version(dir)
                m = FalkorLib::Versioning.minor(v)
                m.should == '5'
            end
            it "#patch -- should collect the Gem patch version" do
                v = FalkorLib::Versioning.get_version(dir)
                m = FalkorLib::Versioning.patch(v)
                m.should == '6'
            end

            it "#set_version -- set Gem version #{default_version} in version file #{versionfile}" do
                STDIN.should_receive(:gets).and_return('Yes')
                v = FalkorLib::Versioning.set_version(default_version, dir)
                v.should == 0
                load "#{versionfile_path}"
                v = FalkorLib::Versioning.get_version(dir)
                v.should == default_version
            end

            #FalkorLib.config[:versioning][:levels].reverse.each do |level|
            [ :patch, :minor ].each do |level|
                it "#set_version #bump -- #{level} bump Gem version number from #{workingversion[:default]} to #{workingversion[level.to_sym]}" do
                    # restore version file
                    STDIN.should_receive(:gets).and_return('Yes')
                    v = FalkorLib::Versioning.set_version(workingversion[:default], dir)
                    v.should == 0
                    load "#{versionfile_path}"
                    v = FalkorLib::Versioning.get_version(dir)
                    v.should == workingversion[:default]
                    # Let's bump
                    v2 = FalkorLib::Versioning.bump(v, level.to_sym)
                    v2.should == workingversion[level.to_sym]
                    STDIN.should_receive(:gets).and_return('Yes')
                    d = FalkorLib::Versioning.set_version(v2, dir)
                    d.should == 0
                    load "#{versionfile_path}"
                    v3 = FalkorLib::Versioning.get_version(dir)
                    v3.should == v2
                end
            end
        end

    end #configatron.temp

end # describe FalkorLib::Versioning