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

    dirs = {
        :without_git => Dir.mktmpdir,
        :with_git    => Dir.mktmpdir,
        :default     => Dir.mktmpdir
    }
    before :all do
        $stdout.sync = true
        #FalkorLib.config[:no_interaction] = true
    end

    after :all do
        dirs.each do |t,d|
            #next if t == :with_git
            FileUtils.remove_entry_secure d
        end
        FalkorLib.config[:no_interaction] = false
    end

    [ :without_git, :with_git ].each do |ctx|
    #[ :with_git ].each do |ctx|
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

            #### Trash creation  #########
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
                gemset = File.basename(dir)
                STDIN.should_receive(:gets).and_return('1') if ctx == :without_git
                STDIN.should_receive(:gets).and_return('')  if ctx == :without_git
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

            it "#rvm -- change targets (ctx = #{ctx}; dir = #{dir})" do
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
                    f = File.join("#{dir}", opts[type.to_sym])
                    t = File.exists?(f)
                    content[type.to_sym] = `cat #{f}`.chomp
                end
                content[:versionfile].should == opts[:ruby]
                content[:gemsetfile].should  == opts[:gemset]
            end


            ### README creation
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

            ### Bootstrap a VERSION file
            it "#versionfile" do
                file    = 'version.txt'
                version = '1.2.14'
                FalkorLib.config[:no_interaction] = true
                FalkorLib::Bootstrap.versionfile(dir,
                                                 {
                                                     :file    => "#{file}",
                                                     :version => "#{version}",
                                                     :no_interaction => true
                                                 })
                t = File.exists?(File.join(dir, file))
                t.should be_true
                v = FalkorLib::Versioning.get_version(dir, { :source => { :filename => file }})
                v.should == "#{version}"
            end

        end # context
    end # each

end
