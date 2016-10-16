require 'spec_helper'
describe FalkorLib do

    it "should have a version number" do
        expect(FalkorLib.const_defined?(:VERSION)).to be true
    end

end
