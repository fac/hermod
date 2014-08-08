require "minitest_helper"

module Hermod
  module Validators
    describe WholeUnits do
      subject do
        WholeUnits.new
      end

      it "allows values that are in whole units" do
        subject.valid?(1.0, {}).must_equal true
      end

      it "raises an error for values with a fractional componant" do
        ex = proc { subject.valid?(3.1415, {}) }.must_raise InvalidInputError
        ex.message.must_equal "must be in whole units"
      end
    end
  end
end
