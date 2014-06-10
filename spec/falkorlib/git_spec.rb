#!/usr/bin/ruby
#########################################
# git_spec.rb
# @author Sebastien Varrette <Sebastien.Varrette@uni.lu>
# Time-stamp: <Mar 2014-06-10 11:28 svarrette>
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

    # before :all do
    #   puts "temp dir : #{dir}"
    # end
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

        if FalkorLib::Git.command? 'subtree'
            it "#subtrees_init - initialize soem Git Subtrees" do
                FalkorLib.config.git do |c|
                    c[:subtrees] = {
                        'easybuild/easyblocks' => {
                            :url    => 'https://github.com/ULHPC/easybuild-easyblocks.git',
                            :branch => 'develop'
                        },
                    }
                end
                b = FalkorLib::Git.subtrees_init( dir )
                b.should == 0
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
