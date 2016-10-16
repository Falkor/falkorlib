#!/usr/bin/ruby
#########################################
# bootstrap_spec.rb
# @author Sebastien Varrette <Sebastien.Varrette@uni.lu>
# Time-stamp: <Sun 2016-10-16 22:05 svarrette>
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
                    expect(c).to eq(0)
                    t = FalkorLib::Git.init?(dir)
                    expect(t).to be true
                end
            end

            #### Trash creation  #########
            it "#trash" do
                c = FalkorLib::Bootstrap.trash(dir)
                t = File.exists?( File.join(dir, FalkorLib.config[:templates][:trashdir], '.gitignore'))
                expect(t).to be true
                expect(c).to eq(0)
            end

            it "#trash - repeat on an existing trash dir" do
                c = FalkorLib::Bootstrap.trash(dir)
                expect(c).to eq(1)
            end

            it "#trash - change target trash dir" do
                newtrashname = 'tmp/mytrash'
                c = FalkorLib::Bootstrap.trash(dir,newtrashname)
                t = File.exists?( File.join(dir, newtrashname, '.gitignore'))
                expect(t).to be true
                expect(c).to eq(0)
            end

            ######### RVM #########
            it "#rvm" do
                gemset = File.basename(dir)
                expect(STDIN).to receive(:gets).and_return('1') if ctx == :without_git
                expect(STDIN).to receive(:gets).and_return('')  if ctx == :without_git
                c = FalkorLib::Bootstrap.rvm(dir)
                expect(c).to eq(0)
                content = {}
                [:versionfile, :gemsetfile].each do |type|
                    f = File.join(dir, FalkorLib.config[:rvm][type.to_sym])
                    t = File.exists?(f)
                    expect(t).to be true
                    content[type.to_sym] = `cat #{f}`.chomp
                end
                expect(content[:versionfile]).to eq(FalkorLib.config[:rvm][:rubies][0])
                expect(content[:gemsetfile]).to  eq(gemset)
            end

            it "#rvm -- repeat" do
                c = FalkorLib::Bootstrap.rvm(dir)
                expect(c).to eq(1)
            end

            it "#rvm -- change targets (ctx = #{ctx}; dir = #{dir})" do
                opts = {
                    :ruby        => '1.2.3',
                    :versionfile => '.myversion',
                    :gemset      => 'newgemset',
                    :gemsetfile  => '.mygemset'
                }
                c = FalkorLib::Bootstrap.rvm(dir, opts)
                expect(c).to eq(0)
                content = {}
                [:versionfile, :gemsetfile].each do |type|
                    f = File.join("#{dir}", opts[type.to_sym])
                    t = File.exists?(f)
                    content[type.to_sym] = `cat #{f}`.chomp
                end
                expect(content[:versionfile]).to eq(opts[:ruby])
                expect(content[:gemsetfile]).to  eq(opts[:gemset])
            end


            ### README creation
            it "#readme" do
                #Array.new(6).each { |e|  STDIN.should_receive(:gets).and_return('') }
                #STDIN.should_receive(:gets).and_return('')
                #STDIN.should_receive(:gets).and_return('1')
                FalkorLib.config[:no_interaction] = true
                FalkorLib::Bootstrap.readme(dir, { :no_interaction => true })
                t = File.exists?(File.join(dir, 'README.md'))
                expect(t).to be true
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
                expect(t).to be true
                v = FalkorLib::Versioning.get_version(dir, { :source => { :filename => file }})
                expect(v).to eq("#{version}")
            end

        end # context
    end # each

end
