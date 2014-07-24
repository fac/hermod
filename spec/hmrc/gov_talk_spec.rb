require 'minitest_helper'

describe HMRC::GovTalk do
  it "should have a version number" do
    HMRC::GovTalk::VERSION.wont_be_nil
  end
end
