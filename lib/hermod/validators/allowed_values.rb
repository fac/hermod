require 'hermod/validators/base'

module Hermod
  module Validators
    # Checks the given value is in a predefined list of allowed values
    class AllowedValues < Base
      attr_reader :allowed_values

      # Sets up the validator with the list of allowed values
      def initialize(allowed_values)
        @allowed_values = allowed_values
      end

      private

      def test
        value.blank? || allowed_values.include?(value)
      end

      def message
        list_of_values = allowed_values.to_sentence(last_word_connector: ", or ", two_words_connector: " or ")
        "must be one of #{list_of_values}, not #{value}"
      end
    end
  end
end
