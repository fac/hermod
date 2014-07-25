require 'hermod/sanitisation'

module Hermod
  # A representation of an XML node with content and attributes.
  class XmlNode
    include Sanitisation

    attr_reader :name, :value, :attributes

    # Internal: creates a XmlNode. This is used by the XmlSection node method and
    # you should probably use that instead.
    #
    # name       - the name of the node as it appears in the XML
    # value      - the node contents as a string.
    # attributes - a Hash of attributes as Symbol -> value pairs. The symbol
    #              must be in ATTRIBUTE_NAMES.
    def initialize(name, value, attributes={})
      @name = name
      @value = value
      @attributes = attributes
    end

    # Internal: turns the XmlNode into an XML::Node
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

    # Public: replaces symbol attributes with strings looked up in the provided
    # hash
    #
    # lookup_hash - the hash to use to convert symbols to strings HMRC recognise
    #
    # Returns self
    def rename_attributes(lookup_hash)
      attributes.keys.each do |attribute|
        attributes[lookup_hash.fetch(attribute)] = sanitize_attribute(attributes.delete(attribute))
      end
      self
    end
  end
end
