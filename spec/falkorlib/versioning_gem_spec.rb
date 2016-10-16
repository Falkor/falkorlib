#!/usr/bin/ruby
#########################################
# versioning_gem_spec.rb
# @author Sebastien Varrette <Sebastien.Varrette@uni.lu>
# Time-stamp: <Sun 2016-10-16 22:13 svarrette>
#
# @description Check the versioning operations on Gems
#
# Copyright (c) 2013 Sebastien Varrette <Sebastien.Varrette@uni.lu>
# .             http://varrette.gforge.uni.lu
##############################################################################

require 'spec_helper'
require 'tmpdir'


describe FalkorLib::Versioning::Gem do

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

	before :all do
		configatron.temp_start
		FalkorLib.config.versioning do |c|
            c[:type] = 'gem'
            c[:source]['gem'][:filename]  = "#{versionfile}"
            c[:source]['gem'][:getmethod] = "::TestGemVersion.version"
        end
	end

    after :all do
        configatron.temp_end
		FileUtils.remove_entry_secure dir
		FalkorLib.config[:versioning][:type] = 'file'
        # configatron.temp do
        #     FalkorLib.config.versioning[:type] = 'file'
        # end
    end

    # configatron.temp do
    #     FalkorLib.config.versioning do |c|
    #         c[:type] = 'gem'
    #         c[:source]['gem'][:filename]  = "#{versionfile}"
    #         c[:source]['gem'][:getmethod] = "::TestGemVersion.version"
    #     end


        ###################################################################
        context 'Test GEM versioning operations within temporary directory' do


            it "#get_version -- NameError on non-existing method" do
                if command?('git_flow')
                    expect(STDIN).to receive(:gets).and_return('Yes')
                    t = FalkorLib::GitFlow.init(dir)
                    expect(t).to eq(0)
                else
                    t = FalkorLib::Git.init(dir)
                    expect(t).to be_truthy
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
                expect(t).to be true
                u = run %{ cat #{versionfile_path} }
                expect(u.to_i).to eq(0)
            end

            it "#get_version -- should get the '#{workingversion[:default]}' version set in the file #{versionfile}" do
                load "#{versionfile_path}"
                v = FalkorLib::Versioning.get_version(dir)
                expect(v).to eq(workingversion[:default])
            end

            it "#major -- should collect the Gem major version" do
                v = FalkorLib::Versioning.get_version(dir)
                m = FalkorLib::Versioning.major(v)
                expect(m).to eq('4')
            end
            it "#minor -- should collect the Gem minor version" do
                v = FalkorLib::Versioning.get_version(dir)
                m = FalkorLib::Versioning.minor(v)
                expect(m).to eq('5')
            end
            it "#patch -- should collect the Gem patch version" do
                v = FalkorLib::Versioning.get_version(dir)
                m = FalkorLib::Versioning.patch(v)
                expect(m).to eq('6')
            end

            it "#set_version -- set Gem version #{default_version} in version file #{versionfile}" do
                expect(STDIN).to receive(:gets).and_return('Yes')
                v = FalkorLib::Versioning.set_version(default_version, dir)
                expect(v).to eq(0)
                load "#{versionfile_path}"
                v = FalkorLib::Versioning.get_version(dir)
                expect(v).to eq(default_version)
            end

            #FalkorLib.config[:versioning][:levels].reverse.each do |level|
            [ :patch, :minor ].each do |level|
                it "#set_version #bump -- #{level} bump Gem version number from #{workingversion[:default]} to #{workingversion[level.to_sym]}" do
                    # restore version file
                    expect(STDIN).to receive(:gets).and_return('Yes')
                    v = FalkorLib::Versioning.set_version(workingversion[:default], dir)
                    expect(v).to eq(0)
                    load "#{versionfile_path}"
                    v = FalkorLib::Versioning.get_version(dir)
                    expect(v).to eq(workingversion[:default])
                    # Let's bump
                    v2 = FalkorLib::Versioning.bump(v, level.to_sym)
                    expect(v2).to eq(workingversion[level.to_sym])
                    expect(STDIN).to receive(:gets).and_return('Yes')
                    d = FalkorLib::Versioning.set_version(v2, dir)
                    expect(d).to eq(0)
                    load "#{versionfile_path}"
                    v3 = FalkorLib::Versioning.get_version(dir)
                    expect(v3).to eq(v2)
                end
            end
        end

    #end #configatron.temp

end # describe FalkorLib::Versioning
