require 'spec_helper'
describe FalkorLib do

  it "should have a version number" do
    expect(FalkorLib.const_defined?(:VERSION)).to be true
  end

  it "should have a Major/Minor/Patch number" do
    [ :MAJOR, :MINOR, :PATCH].each do |t|
      expect(FalkorLib::Version.const_defined?(t)).to be true
    end
  end

  it "self.lib" do
    expect(FalkorLib.lib).to include 'lib'
  end

  it "#self.major" do
    v = FalkorLib::Version::MAJOR
    expect(FalkorLib::Version.major).to eq(v)
  end

  it "#self.minor" do
    v = FalkorLib::Version::MINOR
    expect(FalkorLib::Version.minor).to eq(v)
  end

  it "#self.patch" do
    v = FalkorLib::Version::PATCH
    expect(FalkorLib::Version.patch).to eq(v)
  end

end
