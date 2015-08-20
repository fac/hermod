require "minitest_helper"

module Hermod
  module Validators
    describe NonZero do
      subject do
        NonZero.new
      end

      it "allows positive values" do
        subject.valid?(1, {}).must_equal true
      end

      it "allows negative values" do
        subject.valid?(-1, {}).must_equal true
      end

      it "allows blank values" do
        subject.valid?(nil, {}).must_equal true
      end

      it "raises an error for zero values" do
        ex = proc { subject.valid?(0, {}) }.must_raise InvalidInputError
        ex.message.must_equal "cannot be zero"
      end
    end
  end
end
