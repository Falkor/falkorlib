#!/usr/bin/ruby
#########################################
# gitflow_spec.rb
# @author Sebastien Varrette <Sebastien.Varrette@uni.lu>
# Time-stamp: <Jeu 2013-01-31 23:22 svarrette>
#
# @description Check the
#
# Copyright (c) 2013 Sebastien Varrette <Sebastien.Varrette@uni.lu>
# .             http://varrette.gforge.uni.lu
##############################################################################

require 'spec_helper'
require 'tmpdir'

describe FalkorLib do

    include FalkorLib::Common

    # it "test default initialization of a git-flow dir" do
    #     tempdir = Dir.tmpdir
    #     #puts "tempdir = #{tempdir}"

    #     FalkorLib::GitFlow::init(tempdir)

    #     File.directory?(File.join(tempdir, '.git')).should be_true

    #     g = Git.open(tempdir)
    #     g.config['gitflow.branch.master'].should  == FalkorLib::GitFlow::global_config(:master)
    #     g.config['gitflow.branch.develop'].should == FalkorLib::GitFlow::global_config(:develop)
    #     [ :feature, :release, :hotfix, :support, :versiontag ].each do |e|
    #         g.config["gitflow.prefix.#{e}"].should == FalkorLib::GitFlow::global_config(e.to_sym)
    #     end
    #     FileUtils.rm_rf(tempdir)
    # end

    # [ :master, :develop, :feature, :release, :hotfix, :support, :versiontag ].each do |elem|
	# 	specialvalue = 'uncommonvalue'

	# 	it "test specialized initialization of a git-flow dir (alter '#{elem}' option with special value #{specialvalue})" do
    #         tempdir = Dir.tmpdir
    #         #puts "tempdir = #{tempdir}"

	# 		FalkorLib::GitFlow::init(tempdir, { elem.to_sym => "#{specialvalue}"})
			
    #         File.directory?(File.join(tempdir, '.git')).should be_true

    #         g = Git.open(tempdir)
	# 		[ :master, :develop].each do |e|
	# 			#puts "elem = #{elem}, e = #{e}, ", g.config["gitflow.branch.#{e}"]
	# 			g.config["gitflow.branch.#{e}"].should == ((elem == e) ? specialvalue : FalkorLib::GitFlow::global_config(e.to_sym))
	# 		end
    #         [ :feature, :release, :hotfix, :support, :versiontag ].each do |e|
    #             g.config["gitflow.prefix.#{e}"].should == ((elem == e) ? specialvalue : FalkorLib::GitFlow::global_config(e.to_sym))
    #         end
    #         FileUtils.rm_rf(tempdir)
    #     end
    # end





end
