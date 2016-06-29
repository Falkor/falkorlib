#!/usr/bin/ruby
#########################################
# bootstrap_spec.rb
# @author Sebastien Varrette <Sebastien.Varrette@uni.lu>
# Time-stamp: <Tue 2016-06-28 18:37 svarrette>
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

    dir = Dir.mktmpdir

    before :all do
        $stdout.sync = true
        #FalkorLib.config[:no_interaction] = true
    end

    after :all do
        FileUtils.remove_entry_secure dir
        FalkorLib.config[:no_interaction] = false
    end

    context 'helper functions' do
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

        ### Badges
        it "#get_badge " do
            subject = 'licence'
            status  = 'GPL-2.0'
            t = FalkorLib::Bootstrap.get_badge(subject, status)
            t.should =~ /#{subject}/
            t.should =~ /#{status.sub(/-/, '--')}/
        end
    end # context


    ############################################
    context 'boostrap repo' do
        it '#repo' do
            FalkorLib.config[:no_interaction] = true
            FalkorLib::Bootstrap.repo(dir, { :no_interaction => true, :git_flow => false })
            FalkorLib.config[:no_interaction] = false
        end
    end

    ############################################
    context 'boostrap motd' do
        it "#motd" do
            motdfile = File.join(dir, 'motd1')
            FalkorLib::Bootstrap.motd(dir, { :file => "#{motdfile}", :no_interaction => true })
            t = File.exists?(motdfile)
            t.should be_true
        end
    end

end
