require "minitest_helper"

module Hermod
  module Validators
    describe ValuePresence do
      subject do
        ValuePresence.new
      end

      it "allows values that are present" do
        subject.valid?(1, {}).must_equal true
      end

      it "raises an error for missing values" do
        ex = proc { subject.valid?(nil, {}) }.must_raise InvalidInputError
        ex.message.must_equal "isn't optional but no value was provided"
      end
    end
  end
end
