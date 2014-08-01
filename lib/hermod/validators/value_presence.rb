require 'hermod/validators/base'

module Hermod
  module Validators
    class ValuePresence < Base

      def test
        value.present?
      end

      def message
        "isn't optional but no value was provided"
      end
    end
  end
end
