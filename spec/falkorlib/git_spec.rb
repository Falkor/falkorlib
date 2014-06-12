#!/usr/bin/ruby
#########################################
# git_spec.rb
# @author Sebastien Varrette <Sebastien.Varrette@uni.lu>
# Time-stamp: <Jeu 2014-06-12 10:08 svarrette>
#
# @description Check the Git operation
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
            FalkorLib::Git.init(dir)
            t = FalkorLib::Git.init?(dir)
            t.should be_true
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

        it "#branch? - check non-existing branch" do
            br = FalkorLib::Git.branch?( dir )
            br.should be_nil
        end

        it "#add - makes a first commit" do
            FileUtils.touch( afile )
            FalkorLib::Git.add(afile)
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

        it "#command? - check non-availability of git command 'toto'" do
            c = FalkorLib::Git.command?('toto')
            c.should be_false
        end

        it "#command? - check availability of git command 'init'" do
            c = FalkorLib::Git.command?('init')
            c.should be_true
        end

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

        if FalkorLib::Git.command? 'subtree'
            it "#subtree_init - initialize some Git Subtrees" do
                FalkorLib.config.git do |c|
                    c[:subtrees] = {
                        'falkor/lib' => {
                            :url    => 'https://github.com/Falkor/falkorlib.git',
                            :branch => 'devel'
                        },
                    }
                end
                b = FalkorLib::Git.subtree_init( dir )
                b.should == 0
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

        # # shall be the last check
        # it "#dirty? - check dirty git directory" do
        #   execute "echo 'toto' > #{afile}"
        #     b = FalkorLib::Git.dirty?( dir )
        #     b.should be_true
        # end



    end



end
