require 'hermod/validators/base'

module Hermod
  module Validators
    # Checks a number is not negative
    class NonNegative < Base

      private

      def test(value, attributes)
        value.blank? || value >= 0
      end

      def message(value, attributes)
        "cannot be negative"
      end
    end
  end
end
