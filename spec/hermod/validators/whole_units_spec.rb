require "minitest_helper"

module Hermod
  module Validators
    describe WholeUnits do
      subject do
        WholeUnits.new
      end

      it "allows values that are in whole units" do
        expect(subject.valid?(1.0, {})).must_equal true
      end

      it "allows blank values" do
        expect(subject.valid?(nil, {})).must_equal true
      end

      it "raises an error for values with a fractional componant" do
        ex = expect { subject.valid?(3.1415, {}) }.must_raise InvalidInputError
        expect(ex.message).must_equal "must be in whole units"
      end
    end
  end
end
