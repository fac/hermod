require 'minitest_helper'

describe Hermod do
  it "should have a version number" do
    expect(Hermod::VERSION).wont_be_nil
  end
end
