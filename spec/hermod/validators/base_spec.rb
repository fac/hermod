require "minitest_helper"

module Hermod
  module Validators
    describe Base do
      subject do
        Base.new
      end

      it "doesn't implement a test" do
        expect { subject.valid?(nil, {}) }.must_raise NotImplementedError
      end

      it "has a default error message" do
        class TestValidator < Base
          def test(value, attributes)
            false
          end
        end
        ex = expect { TestValidator.new.valid?(nil, {}) }.must_raise InvalidInputError
        expect(ex.message).must_equal "is invalid"
      end
    end
  end
end
