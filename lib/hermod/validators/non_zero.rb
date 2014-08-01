require 'hermod/validators/base'

module Hermod
  module Validators
    class NonZero < Base

      def test
        value != 0
      end

      def message
        "cannot be zero"
      end
    end
  end
end
