#!/usr/bin/ruby
#########################################
# git_spec.rb
# @author Sebastien Varrette <Sebastien.Varrette@uni.lu>
# Time-stamp: <Jeu 2014-06-05 13:31 svarrette>
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

    dir = Dir.mktmpdir

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
            afile = File.join(dir, 'a_file')
            FileUtils.touch( afile )
            FalkorLib::Git.add(afile)
        end

        it "#branch? - check existing branch" do
            br = FalkorLib::Git.branch?( dir )
            br.should == 'master'
        end

        default_branches.each do |br|
            it "#create_branch #list_branch - creates branch #{br}" do
                FalkorLib::Git.create_branch( br, dir )
                l = FalkorLib::Git.list_branch( dir )
                l.should include "#{br}"
            end
        end

    end



end
