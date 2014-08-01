require 'hermod/validators/base'

module Hermod
  module Validators
    class IsA < Base
      attr_reader :expected_class, :checker

      def initialize(expected_class, &block)
        @expected_class = expected_class
        @checker = block
      end

      def test
        if checker.present?
          checker.call(value)
        else
          value.is_a? expected_class
        end
      end

      def message
        "must be a #{expected_class.name.downcase}"
      end
    end
  end
end
