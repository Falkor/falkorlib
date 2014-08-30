#!/usr/bin/ruby
#########################################
# puppet_modules_spec.rb
# @author Sebastien Varrette <Sebastien.Varrette@uni.lu>
# Time-stamp: <Sat 2014-08-30 21:23 svarrette>
#
# @description Check the Puppet Modules operations
#
# Copyright (c) 2014 Sebastien Varrette <Sebastien.Varrette@uni.lu>
# .             http://varrette.gforge.uni.lu
##############################################################################

require 'spec_helper'
require 'tmpdir'
require 'falkorlib/puppet'

describe FalkorLib::Puppet::Modules do
    include FalkorLib::Common

    dir   = Dir.mktmpdir
    #afile = File.join(dir, 'a_file')
	# before :all do
	# 	ENV['GIT_AUTHOR_NAME']  = 'travis'            if ENV['GIT_AUTHOR_NAME'].nil?
	# 	ENV['GIT_AUTHOR_EMAIL'] = 'travis@domain.org' if ENV['GIT_AUTHOR_EMAIL'].nil?
	# end

    after :all do
        FileUtils.remove_entry_secure dir
    end

    #############################################################
    context "Test Puppet Module creation within temporary directory " do

		# Module name
		name      = 'toto'
		moduledir = File.join(dir, name) 

        it "#init -- create a puppet module" do
			# Prepare answer to the questions
			Array.new(32).each { |e|  STDIN.should_receive(:gets).and_return('') }
			
            FalkorLib::Puppet::Modules.init(moduledir)
            templatedir = File.join( FalkorLib.templates, 'puppet', 'modules')
            s = true
            Dir["#{templatedir}/**/*"].each  do |e|
                next if File.directory?(e)
				relative_dir = Pathname.new( File.realpath( File.dirname(e) )).relative_path_from Pathname.new(templatedir)
				file = e.gsub(/templatename/, "#{name}")
				filename = File.basename(file)
				filename = File.basename(file, '.erb') unless file =~ /templates\/toto-variables\.erb/
				f = File.join(moduledir, relative_dir, filename)
				#puts "checking #{f} - #{File.exists?( f )}"
                s &= File.exists?( f )
            end
            s.should be_true
        end

		it "#classes -- list classes" do
			l = FalkorLib::Puppet::Modules._get_classdefs(moduledir, 'classes')
			c = FalkorLib::Puppet::Modules.classes(moduledir)
			c.should == l
			ref =  [
			        "toto::params",
			        "toto",
			        "toto::common",
			        "toto::debian",
			        "toto::redhat"
			       ]
			c.size.should == ref.size
			c.each { |e| ref.should include(e) }
		end
		
		it "#definitions -- list definitions" do
			d = FalkorLib::Puppet::Modules.definitions(moduledir)
			d.should == [ "toto::mydef" ]
		end

		it "#deps -- list dependencies" do
			d = FalkorLib::Puppet::Modules.deps(moduledir)
			d.should == []
		end





    end
end
