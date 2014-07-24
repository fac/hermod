require 'minitest_helper'

describe XmlSection do
  it "should have a version number" do
    ::XmlSection::VERSION.wont_be_nil
  end

  it "should do something useful" do
    false.must_equal true
  end
end
