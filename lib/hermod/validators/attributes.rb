require 'hermod/validators/base'

module Hermod
  module Validators
    # Checks the attributes are in a list of allowed attributes
    class Attributes < Base
      attr_reader :allowed_attributes, :bad_attributes

      # Public: Sets up the list of allowed attributes
      def initialize(allowed_attributes)
        @allowed_attributes = allowed_attributes
      end

      private

      def test
        @bad_attributes = [] # reset this for each time the validator is used
        attributes.each do |attribute, _|
          bad_attributes << attribute unless allowed_attributes.include? attribute
        end
        bad_attributes == []
      end

      def message
        "has attributes it doesn't accept: #{bad_attributes.to_sentence}"
      end
    end
  end
end
