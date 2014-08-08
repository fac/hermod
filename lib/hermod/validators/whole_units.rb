require 'hermod/validators/base'

module Hermod
  module Validators
    # Checks a decimal value has no decimal componant, i.e. it's just a decimal
    # representation of an integer
    class WholeUnits < Base

      private

      def test
        value == value.to_i
      end

      def message
        "must be in whole units"
      end
    end
  end
end
