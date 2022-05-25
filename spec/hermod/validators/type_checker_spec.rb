require "minitest_helper"

module Hermod
  module Validators
    describe TypeChecker do
      it "uses a default block that checks the value is an instance of the given class" do
        checker = TypeChecker.new(Integer)
        expect(checker.valid?(1, {})).must_equal true
        expect { checker.valid?(1.0, {}) }.must_raise InvalidInputError
      end

      it "allows you to give a block to be more discerning" do
        checker = TypeChecker.new(Integer) { |val| val > 0 }
        expect(checker.valid?(5, {})).must_equal true
        expect { checker.valid?(-2, {}) }.must_raise InvalidInputError
      end

      it "ignores blank values" do
        checker = TypeChecker.new(Integer)
        expect(checker.valid?(nil, {})).must_equal true
      end

      it "gives the correct message" do
        ex = expect { TypeChecker.new(Integer).valid?(1.0, {}) }.must_raise InvalidInputError
        expect(ex.message).must_equal "must be an integer"

        ex = expect { TypeChecker.new(Float).valid?(1, {}) }.must_raise InvalidInputError
        expect(ex.message).must_equal "must be a float"
      end
    end
  end
end
