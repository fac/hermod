require 'active_support/core_ext/array/conversions'

module Hermod
  module Validators
    class Base
      attr_reader :value, :attributes

      def valid?(value, attributes)
        @value, @attributes = value, attributes
        raise(InvalidInputError, message) unless test
      end

      def test
        false
      end

      def message
        "is invalid"
      end
    end
  end
end
