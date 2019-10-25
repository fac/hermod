require 'hermod/validators/base'

module Hermod
  module Validators
    # checks the value is present
    class ValuePresence < Base

      private

      def test(value, attributes)
        value.present?
      end

      def message(value, attributes)
        "isn't optional but no value was provided"
      end
    end
  end
end
