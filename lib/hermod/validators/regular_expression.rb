require 'hermod/validators/base'

module Hermod
  module Validators
    # Checks the value matches the given regular expression
    class RegularExpression < Base
      attr_reader :pattern

      # Sets up the pattern the value is expected to match
      def initialize(pattern)
        @pattern = pattern
      end

      private

      def test
        !!(value =~ pattern)
      end

      def message
        "must match #{pattern.inspect} and #{value} doesn't"
      end
    end
  end
end
