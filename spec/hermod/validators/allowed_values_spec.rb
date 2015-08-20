require "minitest_helper"

module Hermod
  module Validators
    describe AllowedValues do
      subject do
        AllowedValues.new(%w(Antelope Bear Cat Dog Elephant))
      end

      it "permits values in the list" do
        subject.valid?("Cat", {}).must_equal true
      end

      it "allows blank values" do
        subject.valid?("", {}).must_equal true
        subject.valid?(nil, {}).must_equal true
      end

      it "raises an error for values not in the list" do
        ex = proc { subject.valid?("Albatross", {}) }.must_raise InvalidInputError
        ex.message.must_equal "must be one of Antelope, Bear, Cat, Dog, or Elephant, not Albatross"
      end
    end
  end
end
