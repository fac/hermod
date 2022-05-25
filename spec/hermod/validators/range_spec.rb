require "minitest_helper"

module Hermod
  module Validators
    describe Range do
      subject do
        Range.new(1..7)
      end

      it "allows values in the range" do
        expect(subject.valid?(1, {})).must_equal true
        expect(subject.valid?(7, {})).must_equal true
      end

      it "allows blank values" do
        expect(subject.valid?(nil, {})).must_equal true
      end

      it "raises an error for values outwith the range" do
        ex = expect { subject.valid?(0, {}) }.must_raise InvalidInputError
        expect(ex.message).must_equal "must be between 1 and 7"
      end

      it "can also take a min and max as arguments" do
        expect(Range.new(1, 7).valid?(3, {})).must_equal true
      end
    end
  end
end
