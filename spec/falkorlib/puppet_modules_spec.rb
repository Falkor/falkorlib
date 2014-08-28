#!/usr/bin/ruby
#########################################
# puppet_modules_spec.rb
# @author Sebastien Varrette <Sebastien.Varrette@uni.lu>
# Time-stamp: <Thu 2014-08-28 12:17 svarrette>
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

	before :all do
		ENV['GIT_AUTHOR_NAME']  = 'travis'            if ENV['GIT_AUTHOR_NAME'].empty?
		ENV['GIT_AUTHOR_EMAIL'] = 'travis@domain.org' if ENV['GIT_AUTHOR_EMAIL'].empty?
	end

    after :all do
        FileUtils.remove_entry_secure dir
    end

    #############################################################
    context "Test Puppet Module creation within temporary directory " do

        it "#init -- create a puppet module" do
			Array.new(18).each { |e|  STDIN.should_receive(:gets).and_return('') }
            name = 'toto'
            FalkorLib::Puppet::Modules.init(dir, name)
            templatedir = File.join( FalkorLib.templates, 'puppet', 'modules')
            s = true
            Dir["#{templatedir}/**/*"].each  do |e|
                next if File.directory?(e)
				relative_dir = Pathname.new( File.realpath( File.dirname(e) )).relative_path_from Pathname.new(templatedir)
				file = e.gsub(/templatename/, "#{name}")
				filename = File.basename(file)
				filename = File.basename(file, '.erb') unless file =~ /templates\/toto-variables\.erb/
				f = File.join(dir, relative_dir, filename)
				#puts "checking #{f} - #{File.exists?( f )}"
                s &= File.exists?( f )
            end
            s.should be_true
        end


    end
end
