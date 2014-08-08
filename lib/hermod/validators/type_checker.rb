require 'hermod/validators/base'

module Hermod
  module Validators
    # This checks if the given value is an instance of a certain class
    class TypeChecker < Base

      attr_reader :expected_class, :checker

      # Sets up the validator with the class it is expected to be. You can
      # optionally pass a block to customise the class matching logic
      #
      # Examples
      #
      #   TypeChecker.new(Integer)
      #
      #   TypeChecker.new(Date) { |value| value.respond_to? :strftime }
      #
      def initialize(expected_class, &block)
        @expected_class = expected_class
        @checker = block || proc { |value| value.is_a? expected_class }
      end

      private

      def test
        checker.call(value)
      end

      def message
        expected_class_name = expected_class.name.downcase
        join_word = (%w(a e i o u).include?(expected_class_name[0]) ? "an" : "a")
        "must be #{join_word} #{expected_class_name}"
      end
    end
  end
end
