require 'spec_helper'
describe FalkorLib do

    it "should have a version number" do
        FalkorLib.const_defined?(:VERSION).should be_true
    end

end
