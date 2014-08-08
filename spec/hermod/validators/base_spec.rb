require "minitest_helper"

module Hermod
  module Validators
    describe Base do
      subject do
        Base.new
      end

      it "fails validation by default" do
        proc { subject.valid?(nil, {}) }.must_raise InvalidInputError
      end

      it "has a default error message" do
        ex = proc { subject.valid?(nil, {}) }.must_raise InvalidInputError
        ex.message.must_equal "is invalid"
      end
    end
  end
end
