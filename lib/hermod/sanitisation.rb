module Hermod
  module Sanitisation
    # TODO: replace this module with something better
    # Any replacement should make it possible for both yes only attributes and
    # yes/no attributes to work correctly.

    private

    # Private: alters attributes so a true becomes "yes", a no isn't sent and
    # anything else gets turned into a String.
    #
    # value - the non-sanitised value
    #
    # Returns the sanitised value of the attribute ready for sending to HMRC.
    def sanitise_attribute(value)
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
