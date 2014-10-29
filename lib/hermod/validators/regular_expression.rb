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

      # Public: Checks the value matches the pattern. Blank values are ignored
      # because those are checked by the ValuePresence validator if necessary.
      #
      # Returns a boolean
      def test
        value.blank? || value =~ pattern
      end

      def message
        "#{value.inspect} does not match #{pattern.inspect}"
      end
    end
  end
end
