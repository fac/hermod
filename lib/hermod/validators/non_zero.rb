require 'hermod/validators/base'

module Hermod
  module Validators
    # Checks the value is not zero
    class NonZero < Base

      private

      def test(value, attributes)
        value.blank? || value.to_i != 0
      end

      def message(value, attributes)
        "cannot be zero"
      end
    end
  end
end
