#!/usr/bin/ruby
#########################################
# bootstrap_spec.rb
# @author Sebastien Varrette <Sebastien.Varrette@uni.lu>
# Time-stamp: <Lun 2015-03-09 17:09 svarrette>
#
# @description Check the Bootstrapping operations
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
        :default     => Dir.mktmpdir
    }
    before :all do
        $stdout.sync = true
    end

    after :all do
        dirs.each do |t,d|
            FileUtils.remove_entry_secure d
        end
        FalkorLib.config[:no_interaction] = false
    end

    [ :without_git, :with_git ].each do |ctx|
        dir = dirs[ctx]
        #############################################################
        context "Test bootstrapping operations within (#{ctx}) temporary directory #{dir} " do

            if ctx == :with_git
                it "initialize Git in the temporary directory #{dir}" do
                    c = FalkorLib::Git.init(dir)
			        c.should == 0
                    t = FalkorLib::Git.init?(dir)
                    t.should be_true
                end
            end

            ######### Trash creation  #########
            it "#trash" do
                c = FalkorLib::Bootstrap.trash(dir)
                t = File.exists?( File.join(dir, FalkorLib.config[:templates][:trashdir], '.gitignore'))
                t.should be_true
                c.should == 0
            end

            it "#trash - repeat on an existing trash dir" do
                c = FalkorLib::Bootstrap.trash(dir)
                c.should == 1
            end

            it "#trash - change target trash dir" do
                newtrashname = 'tmp/mytrash'
                c = FalkorLib::Bootstrap.trash(dir,newtrashname)
                t = File.exists?( File.join(dir, newtrashname, '.gitignore'))
                t.should be_true
                c.should == 0
            end

            ######### RVM #########
            it "#rvm" do
                gemset = 'mygemset'
                STDIN.should_receive(:gets).and_return('1')
                STDIN.should_receive(:gets).and_return(gemset)
                c = FalkorLib::Bootstrap.rvm(dir)
                c.should == 0
                content = {}
                [:versionfile, :gemsetfile].each do |type|
                    f = File.join(dir, FalkorLib.config[:rvm][type.to_sym])
                    t = File.exists?(f)
                    t.should be_true
                    content[type.to_sym] = `cat #{f}`.chomp
                end
                content[:versionfile].should == FalkorLib.config[:rvm][:rubies][0]
                content[:gemsetfile].should  == gemset
            end

            it "#rvm -- repeat" do
                c = FalkorLib::Bootstrap.rvm(dir)
                c.should == 1
            end

            it "#rvm -- change targets" do
                opts = {
                    :ruby        => '1.2.3',
                    :versionfile => '.myversion',
                    :gemset      => 'newgemset',
                    :gemsetfile  => '.mygemset'
                }
                c = FalkorLib::Bootstrap.rvm(dir, opts)
                c.should == 0
                content = {}
                [:versionfile, :gemsetfile].each do |type|
                    f = File.join(dir, opts[type.to_sym])
                    t = File.exists?(f)
                    t.should be_true
                    content[type.to_sym] = `cat #{f}`.chomp
                end
                content[:versionfile].should == opts[:ruby]
                content[:gemsetfile].should  == opts[:gemset]
            end

            it "#select_forge - none" do
			    STDIN.should_receive(:gets).and_return('1')
                t = FalkorLib::Bootstrap.select_forge()
                t.should == :none
            end

            it "#select_forge -- default to github" do
                STDIN.should_receive(:gets).and_return('')
                t = FalkorLib::Bootstrap.select_forge(:github)
                t.should == :github
            end

            FalkorLib::Config::Bootstrap::DEFAULTS[:licenses].keys.each do |lic|
                it "#select_licence -- default to #{lic}" do
                    STDIN.should_receive(:gets).and_return('')
                    t = FalkorLib::Bootstrap.select_licence(lic)
                    t.should == lic
                end
            end

            it "#get_badge " do
                subject = 'licence'
                status  = 'GPL-2.0'
                t = FalkorLib::Bootstrap.get_badge(subject, status)
                t.should =~ /#{subject}/
                t.should =~ /#{status.sub(/-/, '--')}/
            end

            it "#readme" do
                #Array.new(6).each { |e|  STDIN.should_receive(:gets).and_return('') }
                #STDIN.should_receive(:gets).and_return('')
                #STDIN.should_receive(:gets).and_return('1')
                FalkorLib.config[:no_interaction] = true
                FalkorLib::Bootstrap.readme(dir, { :no_interaction => true })
                t = File.exists?(File.join(dir, 'README.md'))
                t.should be_true
                FalkorLib.config[:no_interaction] = false
            end
        end # context

    end # each
    
    ############################################
    context 'boostrap repo' do
        dir = dirs[:default]
        
        it '#repo' do
            FalkorLib.config[:no_interaction] = true
            FalkorLib::Bootstrap.repo(dir, { :no_interaction => true, :git_flow => false })
            FalkorLib.config[:no_interaction] = false
        end

    end

    
end
