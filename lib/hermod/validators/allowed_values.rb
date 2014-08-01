require 'hermod/validators/base'

module Hermod
  module Validators
    class AllowedValues < Base
      attr_reader :allowed_values

      def initialize(allowed_values)
        @allowed_values = allowed_values
      end

      def test
        allowed_values.include? value
      end

      def message
        "must be one of #{allowed_values.to_sentence}, not #{value}"
      end
    end
  end
end
