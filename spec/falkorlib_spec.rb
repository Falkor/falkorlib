require 'spec_helper'
describe FalkorLib do

    it "should have a version number" do
        expect(FalkorLib.const_defined?(:VERSION)).to be true
    end

    it "self.lib" do
      expect(FalkorLib.lib).to include 'lib'
    end


end
