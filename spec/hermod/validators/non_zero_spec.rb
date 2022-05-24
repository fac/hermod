require "minitest_helper"

module Hermod
  module Validators
    describe NonZero do
      subject do
        NonZero.new
      end

      it "allows positive values" do
        expect(subject.valid?(1, {})).must_equal true
      end

      it "allows negative values" do
        expect(subject.valid?(-1, {})).must_equal true
      end

      it "allows blank values" do
        expect(subject.valid?(nil, {})).must_equal true
      end

      it "raises an error for zero values" do
        ex = expect { subject.valid?(0, {}) }.must_raise InvalidInputError
        expect(ex.message).must_equal "cannot be zero"
      end
    end
  end
end
