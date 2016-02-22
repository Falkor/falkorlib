#!/usr/bin/ruby
#########################################
# git_spec.rb
# @author Sebastien Varrette <Sebastien.Varrette@uni.lu>
# Time-stamp: <Mon 2016-02-22 23:34 svarrette>
#
# @description Check the Git operations
#
# Copyright (c) 2013 Sebastien Varrette <Sebastien.Varrette@uni.lu>
# .             http://varrette.gforge.uni.lu
##############################################################################

require 'spec_helper'
require 'tmpdir'

describe FalkorLib::Git do

    include FalkorLib::Common
    default_branches = [ 'devel', 'production' ]

    dir   = Dir.mktmpdir
    afile = File.join(dir, 'a_file')

    before :all do
        $stdout.sync = true
    end

    after :all do
        FileUtils.remove_entry_secure dir
    end

    #############################################################
    context "Test git operations within temporary directory " do

        it "#init? - fails on non-git directory" do
            t = FalkorLib::Git.init?(dir)
            t.should be_false
        end

        it "#init - initialize a git repository" do
            c = FalkorLib::Git.init(dir)
            c.should == 0
            t = FalkorLib::Git.init?(dir)
            t.should be_true
        end

        it "#remotes? -- should be false" do
            t = FalkorLib::Git.remotes?(dir)
            t.should be_false
        end

        it "#rootdir #gitdir - checks git dir and working tree" do
            subdir = File.join(dir, 'some_dir')
            Dir.mkdir( subdir )
            Dir.chdir( subdir ) do
                r = File.realpath( FalkorLib::Git.rootdir )
                g = FalkorLib::Git.gitdir
                r.should == File.realpath(dir)
                g.should == File.realpath( File.join(dir, '.git')  )
            end
        end

        it "#has_commits? - not yet any commits" do
            b = FalkorLib::Git.has_commits?( dir )
            b.should be_false
        end

        it "#branch? - check non-existing branch" do
            br = FalkorLib::Git.branch?( dir )
            br.should be_nil
        end

        it "#list_files -- should not list any files" do
            l = FalkorLib::Git.list_files( dir )
            l.should be_empty
        end

        it "#add - makes a first commit" do
            FileUtils.touch( afile )
            t = FalkorLib::Git.add(afile)
            t.should == 0
        end

        it "#list_files -- should list a single files" do
            l = FalkorLib::Git.list_files( dir )
            l.should include 'a_file'
        end


        it "#has_commits? - no some commits have been done" do
            b = FalkorLib::Git.has_commits?( dir )
            b.should be_true
        end


        it "#branch? - check existing branch" do
            br = FalkorLib::Git.branch?( dir )
            br.should == 'master'
        end

        it "#dirty? - check non-dirty git directory" do
            b = FalkorLib::Git.dirty?( dir )
            b.should be_false
        end

        default_branches.each do |br|
            it "#create_branch #list_branch - creates branch #{br}" do
                FalkorLib::Git.create_branch( br, dir )
                l = FalkorLib::Git.list_branch( dir )
                l.should include "#{br}"
            end
        end

        default_branches.each do |br|
            it "#delete_branch #list_branch - deletes branch #{br}" do
                FalkorLib::Git.delete_branch( br, dir) #, :force => true )
                l = FalkorLib::Git.list_branch( dir )
                l.should_not include "#{br}"
            end
        end

        it "#command? - check non-availability of git command 'toto'" do
            c = FalkorLib::Git.command?('toto')
            c.should be_false
        end

        it "#command? - check availability of git command 'init'" do
            c = FalkorLib::Git.command?('init')
            c.should be_true
        end

        it "#config -- check existing key" do
            c = FalkorLib::Git.config('user.name', dir)
            c.should_not be_empty
            t = c.is_a? String
            t.should be_true
        end

        it "#config -- check non-existing key" do
            c = FalkorLib::Git.config('user.nam', dir)
            c.should be_nil
        end

        it "#config -- check all keys" do
            c = FalkorLib::Git.config('*', dir)
            c.should_not be_empty
            t = c.is_a? Array
            t.should be_true
        end

        it "#config -- check pattern" do
            c = FalkorLib::Git.config('user*', dir)
            c.should_not be_empty
            t = c.is_a? Array
            t.should be_true
            ap c
            c.length.should >= 2
        end

        it "#config -- check pattern 2" do
            c = FalkorLib::Git.config(/.*name=/, dir)
            c.should_not be_empty
            t = c.is_a? Array
            t.should be_true
            c.length.should == 1
        end

        it "#config -- return hash" do
            c = FalkorLib::Git.config('user*', dir, :hash => true)
            c.should_not be_empty
            t = c.is_a? Hash
            t.should be_true
            ap c
            c.keys.length.should >= 2
        end

        it "#config -- check hash correctness" do
            key = 'user.name'
            c = FalkorLib::Git.config('user*', dir, :hash => true)
            n = FalkorLib::Git.config('user.name', dir)
            n.should == c[ key ]
        end

        # ---------- Submodules ---------------
        it "#submodules_init" do
            FalkorLib.config.git do |c|
                c[:submodules] = {
                    'falkorgit' => {
                        :url    => 'https://github.com/Falkor/falkorlib.git',
                        :branch => 'devel'
                    }
                }
            end
            b = FalkorLib::Git.submodule_init( dir )
            b.should == 0
        end

        it "#submodules_update" do
            b = FalkorLib::Git.submodule_update( dir )
            b.should == 0
        end

        it "#submodules_upgrade" do
            b = FalkorLib::Git.submodule_upgrade( dir )
            b.should == 0
        end

        # ---------- Subtrees ---------------
        if FalkorLib::Git.command? 'subtree'
            FalkorLib.config.git do |c|
                c[:subtrees] = {
                    'falkor/lib' => {
                        :url    => 'https://github.com/Falkor/falkorlib.git',
                        :branch => 'devel'
                    },
                }
            end

            it "#subtree_init? -- should check that the subtree(s) have not been initialized" do
                b = FalkorLib::Git.subtree_init?( dir )
                b.should be_false
            end

            it "#subtree_init - initialize some Git Subtrees" do

                b = FalkorLib::Git.subtree_init( dir )
                b.should == 0
            end

            it "#subtree_init? -- should check that the subtree(s) have been initialized" do
                b = FalkorLib::Git.subtree_init?( dir )
                b.should be_true
            end

            it "#subtree_up" do
                b = FalkorLib::Git.subtree_up( dir )
                b.should == 0
            end

            it "#subtree_diff" do
                b = FalkorLib::Git.subtree_diff( dir )
                b.should == 0
                puts FalkorLib::Git.dirty?( dir )
            end
        end




        # shall be the last check
        it "#dirty? - check dirty git directory" do
            execute "echo 'toto' > #{afile}"
            b = FalkorLib::Git.dirty?( dir )
            b.should be_true
        end

    end



end
