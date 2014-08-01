require 'hermod/validators/base'

module Hermod
  module Validators
    class Range < Base
      attr_reader :min, :max

      def initialize(min, max)
        @min, @max = min, max
      end

      def test
        min <= value && max >= value
      end

      def message
        "must be between #{min} and #{max}"
      end
    end
  end
end
