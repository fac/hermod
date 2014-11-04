require 'hermod/validators/base'

module Hermod
  module Validators
    # Checks a number is not negative
    class NonNegative < Base

      private

      def test
        value.blank? || value >= 0
      end

      def message
        "cannot be negative"
      end
    end
  end
end
