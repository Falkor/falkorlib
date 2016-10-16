require 'spec_helper'
require 'tempfile'

describe FalkorLib::Config do

    include FalkorLib::Common

	dir   = Dir.mktmpdir
    test_hash = {
                    :str   => "simple string",
                    :array => [ 'a', 'b' ],
                    :hash  => {
                               :key => 'val'
                              }
                   }

    after :all do
        FileUtils.remove_entry_secure dir
    end

	#############################################
    context "Test default configuration object" do

		it "#default" do
            hash = FalkorLib::Config.default
            t = hash.is_a? Hash
            t.should be true
            hash[:rvm][:versionfile].should == FalkorLib::Config::DEFAULTS[:rvm][:versionfile]
        end

        it "#save" do
            FalkorLib::Config.save(dir, test_hash, :local, { :no_interaction => true })
            t = File.exists?( File.join(dir, FalkorLib::Config::DEFAULTS[:config_files][:local]))
            t. should be true
        end

        it "#get" do
            h = FalkorLib::Config.get(dir, :local, { :no_interaction => true })
            h.should == test_hash
        end

	end


end
