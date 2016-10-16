#!/usr/bin/ruby
#########################################
# git_spec.rb
# @author Sebastien Varrette <Sebastien.Varrette@uni.lu>
# Time-stamp: <Sun 2016-10-16 22:05 svarrette>
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
            expect(t).to be false
        end

        it "#init - initialize a git repository" do
            c = FalkorLib::Git.init(dir)
            expect(c).to eq(0)
            t = FalkorLib::Git.init?(dir)
            expect(t).to be true
        end

        it "#remotes? -- should be false" do
            t = FalkorLib::Git.remotes?(dir)
            expect(t).to be false
        end

        it "#rootdir #gitdir - checks git dir and working tree" do
            subdir = File.join(dir, 'some_dir')
            Dir.mkdir( subdir )
            Dir.chdir( subdir ) do
                r = File.realpath( FalkorLib::Git.rootdir )
                g = FalkorLib::Git.gitdir
                expect(r).to eq(File.realpath(dir))
                expect(g).to eq(File.realpath( File.join(dir, '.git')  ))
            end
        end

        it "#has_commits? - not yet any commits" do
            b = FalkorLib::Git.has_commits?( dir )
            expect(b).to be false
        end

        it "#branch? - check non-existing branch" do
            br = FalkorLib::Git.branch?( dir )
            expect(br).to be_nil
        end

        it "#list_files -- should not list any files" do
            l = FalkorLib::Git.list_files( dir )
            expect(l).to be_empty
        end

        it "#add - makes a first commit" do
            FileUtils.touch( afile )
            t = FalkorLib::Git.add(afile)
            expect(t).to eq(0)
        end

        it "#list_files -- should list a single files" do
            l = FalkorLib::Git.list_files( dir )
            expect(l).to include 'a_file'
        end


        it "#has_commits? - no some commits have been done" do
            b = FalkorLib::Git.has_commits?( dir )
            expect(b).to be true
        end


        it "#branch? - check existing branch" do
            br = FalkorLib::Git.branch?( dir )
            expect(br).to eq('master')
        end

        it "#dirty? - check non-dirty git directory" do
            b = FalkorLib::Git.dirty?( dir )
            expect(b).to be false
        end

        default_branches.each do |br|
            it "#create_branch #list_branch - creates branch #{br}" do
                FalkorLib::Git.create_branch( br, dir )
                l = FalkorLib::Git.list_branch( dir )
                expect(l).to include "#{br}"
            end
        end

        default_branches.each do |br|
            it "#delete_branch #list_branch - deletes branch #{br}" do
                FalkorLib::Git.delete_branch( br, dir) #, :force => true )
                l = FalkorLib::Git.list_branch( dir )
                expect(l).not_to include "#{br}"
            end
        end

        it "#command? - check non-availability of git command 'toto'" do
            c = FalkorLib::Git.command?('toto')
            expect(c).to be false
        end

        it "#command? - check availability of git command 'init'" do
            c = FalkorLib::Git.command?('init')
            expect(c).to be true
        end

        it "#config -- check existing key" do
            c = FalkorLib::Git.config('user.name', dir)
            expect(c).not_to be_empty
            t = c.is_a? String
            expect(t).to be true
        end

        it "#config -- check non-existing key" do
            c = FalkorLib::Git.config('user.nam', dir)
            expect(c).to be_nil
        end

        it "#config -- check all keys" do
            c = FalkorLib::Git.config('*', dir)
            expect(c).not_to be_empty
            t = c.is_a? Array
            expect(t).to be true
        end

        it "#config -- check pattern" do
            c = FalkorLib::Git.config('user*', dir)
            expect(c).not_to be_empty
            t = c.is_a? Array
            expect(t).to be true
            ap c
            expect(c.length).to be >= 2
        end

        it "#config -- check pattern 2" do
            c = FalkorLib::Git.config(/.*name=/, dir)
            expect(c).not_to be_empty
            t = c.is_a? Array
            expect(t).to be true
            expect(c.length).to eq(1)
        end

        it "#config -- return hash" do
            c = FalkorLib::Git.config('user*', dir, :hash => true)
            expect(c).not_to be_empty
            t = c.is_a? Hash
            expect(t).to be true
            ap c
            expect(c.keys.length).to be >= 2
        end

        it "#config -- check hash correctness" do
            key = 'user.name'
            c = FalkorLib::Git.config('user*', dir, :hash => true)
            n = FalkorLib::Git.config('user.name', dir)
            expect(n).to eq(c[ key ])
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
            expect(b).to eq(0)
        end

        it "#submodules_update" do
            b = FalkorLib::Git.submodule_update( dir )
            expect(b).to eq(0)
        end

        it "#submodules_upgrade" do
            b = FalkorLib::Git.submodule_upgrade( dir )
            expect(b).to eq(0)
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
                expect(b).to be false
            end

            it "#subtree_init - initialize some Git Subtrees" do

                b = FalkorLib::Git.subtree_init( dir )
                expect(b).to eq(0)
            end

            it "#subtree_init? -- should check that the subtree(s) have been initialized" do
                b = FalkorLib::Git.subtree_init?( dir )
                expect(b).to be true
            end

            it "#subtree_up" do
                b = FalkorLib::Git.subtree_up( dir )
                expect(b).to eq(0)
            end

            it "#subtree_diff" do
                b = FalkorLib::Git.subtree_diff( dir )
                expect(b).to eq(0)
                puts FalkorLib::Git.dirty?( dir )
            end
        end




        # shall be the last check
        it "#dirty? - check dirty git directory" do
            execute "echo 'toto' > #{afile}"
            b = FalkorLib::Git.dirty?( dir )
            expect(b).to be true
        end

    end



end
