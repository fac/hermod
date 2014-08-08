require "minitest_helper"

module Hermod
  module Validators
    describe Attributes do
      subject do
        Attributes.new([:species, :genus])
      end

      it "permits attributes in the list" do
        subject.valid?(nil, {species: "Felis catus", genus: "Felis"}).must_equal true
      end

      it "raises an error for attributes not in the list" do
        ex = proc { subject.valid?(nil, {phylum: "Chordata"}) }.must_raise InvalidInputError
        ex.message.must_equal "has attributes it doesn't accept: phylum"
      end
    end
  end
end
