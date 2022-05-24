require 'hermod/validators/base'

module Hermod
  module Validators
    # Checks the attributes are in a list of allowed attributes
    class Attributes < Base
      attr_reader :allowed_attributes

      # Public: Sets up the list of allowed attributes
      def initialize(allowed_attributes)
        @allowed_attributes = allowed_attributes
      end

      private

      def bad_attributes(attributes)
        attributes.map do |attribute, _|
          attribute unless allowed_attributes.include? attribute
        end.compact
      end

      def test(value, attributes)
        bad_attributes(attributes) == []
      end

      def message(value, attributes)
        "has attributes it doesn't accept: #{bad_attributes(attributes).to_sentence}"
      end
    end
  end
end
