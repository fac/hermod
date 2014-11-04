require "minitest_helper"

module Hermod
  module Validators
    describe NonNegative do
      subject do
        NonNegative.new
      end

      it "allows positive values" do
        subject.valid?(1, {}).must_equal true
      end

      it "allows zero values" do
        subject.valid?(0, {}).must_equal true
      end

      it "allows blank values" do
        subject.valid?(nil, {}).must_equal true
      end

      it "raises an error for negative values" do
        ex = proc { subject.valid?(-1, {}) }.must_raise InvalidInputError
        ex.message.must_equal "cannot be negative"
      end
    end
  end
end
