require 'minitest_helper'

describe HMRC::GovTalk::XmlSection do
  it "should have a version number" do
    ::HMRC::GovTalk::XmlSection::VERSION.wont_be_nil
  end

  it "should do something useful" do
    false.must_equal true
  end
end
