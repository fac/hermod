require 'minitest_helper'

describe Hermod do
  it "should have a version number" do
    Hermod::VERSION.wont_be_nil
  end
end
