require "minitest_helper"

module Hermod
  module Validators
    describe RegularExpression do
      subject do
        RegularExpression.new(/\A[A-Z]{2} [0-9]{6} [A-D]\z/x)
      end

      it "allows values that match the pattern" do
        subject.valid?("AB123456C", {}).must_equal true
      end

      it "raises an error for values that don't match the pattern" do
        ex = proc { subject.valid?("fish", {}) }.must_raise InvalidInputError
        ex.message.must_equal "\"fish\" does not match /\\A[A-Z]{2} [0-9]{6} [A-D]\\z/x"
      end
    end
  end
end
