require 'hermod/validators/base'

module Hermod
  module Validators
    class RegularExpression < Base
      attr_reader :pattern

      def initialize(pattern)
        @pattern = pattern
      end

      def test
        value =~ pattern
      end

      def message
        "must match #{pattern.source} and #{value} doesn't"
      end
    end
  end
end
