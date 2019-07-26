require 'active_support/core_ext/array/conversions'

module Hermod
  module Validators
    class Base
      # Public: Runs the test for the validator returning true if it passes and
      # raising if it fails
      #
      # Raises a Hermod::InvalidInputError if the test fails
      # Returns true if it succeeds
      def valid?(value, attributes)
        !!test(value, attributes) || raise(InvalidInputError, message(value, attributes))
      end

      private

      # Private: override in subclasses to implement the logic for that
      # validator
      #
      # Returns a boolean
      def test(value, attributes)
        raise NotImplementedError
      end

      # Private: override in subclasses to provide a more useful error message
      #
      # Returns a string
      def message(value, attributes)
        "is invalid"
      end
    end
  end
end
