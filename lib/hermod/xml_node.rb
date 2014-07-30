require 'hermod/sanitisation'

module Hermod
  # A representation of an XML node with content and attributes.
  class XmlNode
    include Sanitisation

    attr_reader :name, :value, :attributes

    # Internal: creates a XmlNode. This is used by the XmlSectionBuilder's node
    # building methods and should not be called manually.
    #
    # name       - the name of the node as it appears in the XML
    # value      - the node contents as a string.
    # attributes - a Hash of attributes as Symbol -> value pairs. The symbol
    #              must be in the list of attributes allowed for the node as
    #              set in the builder.
    def initialize(name, value, attributes={})
      @name = name
      @value = value
      @attributes = attributes
    end

    # Internal: turns the XmlNode into an XML::Node including any attributes
    # without any sanitisation (currently - this may change in a future
    # version).
    #
    # Returns an XML::Node built from the XmlNode object.
    def to_xml
      if value.respond_to? :to_xml
        value.to_xml
      else
        XML::Node.new(@name, @value).tap do |node|
          @attributes.each do |attribute_name, attribute_value|
            node[attribute_name] = attribute_value if attribute_value.present?
          end
        end
      end
    end

    # Internal: replaces symbol attributes with strings looked up in the provided
    # hash
    #
    # lookup_hash - the hash to use to convert symbols to strings HMRC recognise
    #
    # Returns self so it can be used in a call chain (This may change in
    # future)
    def rename_attributes(lookup_hash)
      attributes.keys.each do |attribute|
        attributes[lookup_hash.fetch(attribute)] = sanitise_attribute(attributes.delete(attribute))
      end
      self
    end
  end
end
