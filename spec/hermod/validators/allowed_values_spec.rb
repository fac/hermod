require "minitest_helper"

module Hermod
  module Validators
    describe AllowedValues do
      subject do
        AllowedValues.new(%w(Antelope Bear Cat Dog Elephant))
      end

      it "permits values in the list" do
        expect(subject.valid?("Cat", {})).must_equal true
      end

      it "allows blank values" do
        expect(subject.valid?("", {})).must_equal true
        expect(subject.valid?(nil, {})).must_equal true
      end

      it "raises an error for values not in the list" do
        ex = expect { subject.valid?("Albatross", {}) }.must_raise InvalidInputError
        expect(ex.message).must_equal "must be one of Antelope, Bear, Cat, Dog, or Elephant, not Albatross"
      end
    end
  end
end
