require 'hermod/validators/base'

module Hermod
  module Validators
    # Checks a value is in the given range
    class Range < Base
      attr_reader :range

      def initialize(range_or_min, max = nil)
        if max
          @range = range_or_min..max
        else
          @range = range_or_min
        end
      end

      private

      def test(value, attributes)
        value.blank? || range.cover?(value)
      end

      def message(value, attributes)
        "must be between #{range.min} and #{range.max}"
      end
    end
  end
end
