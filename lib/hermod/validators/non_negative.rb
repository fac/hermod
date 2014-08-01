require 'hermod/validators/base'

module Hermod
  module Validators
    class NonNegative < Base

      def test
        value >= 0
      end

      def message
        "cannot be negative"
      end
    end
  end
end
