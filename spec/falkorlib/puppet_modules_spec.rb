#!/usr/bin/ruby
#########################################
# puppet_modules_spec.rb
# @author Sebastien Varrette <Sebastien.Varrette@uni.lu>
# Time-stamp: <Sun 2014-08-31 17:33 svarrette>
#
# @description Check the Puppet Modules operations
#
# Copyright (c) 2014 Sebastien Varrette <Sebastien.Varrette@uni.lu>
# .             http://varrette.gforge.uni.lu
##############################################################################

require 'spec_helper'
require 'tmpdir'
require 'falkorlib/puppet'
require 'json'

describe FalkorLib::Puppet::Modules do
    include FalkorLib::Common

    dir   = Dir.mktmpdir
	# Module name
	name      = 'toto'
	moduledir = File.join(dir, name)
	jsonfile = File.join( moduledir, 'metadata.json') 

    #afile = File.join(dir, 'a_file')
    # before :all do
    #   ENV['GIT_AUTHOR_NAME']  = 'travis'            if ENV['GIT_AUTHOR_NAME'].nil?
    #   ENV['GIT_AUTHOR_EMAIL'] = 'travis@domain.org' if ENV['GIT_AUTHOR_EMAIL'].nil?
    # end

    after :all do
        FileUtils.remove_entry_secure dir
    end

    #############################################################
    context "Test Puppet Module creation within temporary directory " do


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

		it "#_getclassdefs -- should failed on unrecogized type" do
			expect { FalkorLib::Puppet::Modules._get_classdefs(dir, 'toto') }.to raise_error (SystemExit)
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

        it "#upgrade" do
            Array.new(3).each { |e| STDIN.should_receive(:gets).and_return('') }
            d = FalkorLib::Puppet::Modules.upgrade(moduledir)
        end

        it "#parse" do
            STDIN.should_receive(:gets).and_return('')
            ref = JSON.parse( IO.read( jsonfile ) )
            metadata = FalkorLib::Puppet::Modules.parse(moduledir)
            diff = (metadata.to_a - ref.to_a).flatten
            diff.should == [
                            'classes',
                            'toto::params',
                            'toto',
                            'toto::common',
                            'toto::debian',
                            'toto::redhat',
                            'definitions',
                            'toto::mydef',
                           ]
        end

		it "#parse again" do
			metadata = FalkorLib::Puppet::Modules.parse(moduledir)
			metadata.should == []
		end

		it "#deps -- should find a new dependency" do
			classfile = File.join(moduledir, 'manifests', 'classes', 'toto.pp')
			newdep = "tata"
			run %{ echo 'include "#{newdep}"' >> #{classfile} }
			a = FalkorLib::Puppet::Modules.deps(moduledir)
			a.should include newdep 
		end

		it "#parse -- should ask new dependency elements" do
			ref      = JSON.parse( IO.read( jsonfile ) )
			STDIN.should_receive(:gets).and_return('svarrette')
			STDIN.should_receive(:gets).and_return('1.2')
			STDIN.should_receive(:gets).and_return('Yes')
			metadata = FalkorLib::Puppet::Modules.parse(moduledir)
			diff = (metadata.to_a - ref.to_a).flatten
			diff.should == [
			                'dependencies',
			                {"name"=>"puppetlabs-stdlib", "version_range"=>">= 1.0.0"}, 
			                {"name"=>"svarrette/tata", "version_requirement"=>"1.2"}
			               ]
		end
    end # context

end
