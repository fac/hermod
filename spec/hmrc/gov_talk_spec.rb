require 'minitest_helper'

module HMRC
  describe GovTalk do
    it "should have a version number" do
      GovTalk::VERSION.wont_be_nil
    end
  end
end
