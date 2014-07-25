module Hermod
  module Sanitisation

    private

    def sanitize_attribute(value)
      case value
      when true
        XmlSectionBuilder::YES
      when false
        nil # Attributes aren't included if they're false
      else
        value.to_s
      end
    end
  end
end
