require 'hermod/validators/base'

module Hermod
  module Validators
    class Attributes < Base
      attr_reader :allowed_attributes, :bad_attributes

      def initialize(allowed_attributes)
        @bad_attributes = []
        @allowed_attributes = allowed_attributes
      end

      def test
        attributes.all? do |attribute, _|
          allowed_attributes.include? attribute
        end
      end

      def message
        "has attributes it doesn't accept: #{bad_attributes.to_sentence}"
      end
    end
  end
end
