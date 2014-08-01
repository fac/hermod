require 'hermod/validators/base'

module Hermod
  module Validators
    class WholeUnits < Base

      def test
        value == value.to_i
      end

      def message
        "must be in whole pounds"
      end
    end
  end
end
