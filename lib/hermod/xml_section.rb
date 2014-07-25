require 'xml'
require 'hermod/xml_section_builder'
require 'hermod/sanitisation'

module Hermod
  # A representation of a section of XML sent to HMRC using the Government
  # Gateway
  class XmlSection
    include Sanitisation

    # Public: builds a new class using the XmlSectionBuilder DSL
    #
    # Returns the new Class
    def self.build(options = {}, &block)
      Class.new(XmlSection).tap do |new_class|
        options.each do |name, value|
          new_class.public_send "#{name}=", value
        end
        XmlSectionBuilder.new(new_class).build(&block)
      end
    end

    attr_reader :attributes

    # Public: turns the XmlSection into an XML::Node instance (from
    # libxml-ruby). This creates this as a node, adds any attributes (after
    # sanitising them according to HMRC's rules) and then adds child nodes in
    # the order they were defined in the DSL. Nodes that have been called multiple
    # times are added in the order they were called.
    #
    # Returns an XML::Node
    def to_xml
      XML::Node.new(self.class.xml_name).tap do |root_node|
        # Add attributes
        attributes.each do |attribute_name, attribute_value|
          sane_value = sanitise_attribute(attribute_value)
          root_node[attribute_name] = sane_value if sane_value.present?
        end
        # Add child nodes
        self.class.node_order.each do |node_name|
          nodes[node_name].each do |node|
            root_node << node.to_xml
          end
        end
      end
    end

    # Internal: creates an XmlSection. This shouldn't normally be called
    # directly, instead the subclasses call it as they define a useful
    # NODE_ORDER.
    #
    # name  - a Symbol that corresponds to the node name in NODE_ORDER
    # block - a Block that will be executed in the context of this class for
    #         setting up descendents.
    def initialize(attributes={}, &block)
      @attributes = attributes
      yield self
    end

    class << self
      attr_writer :xml_name, :formats
      attr_accessor :node_order
    end

    # Internal: a class method for getting the name of the XML node used when
    # converting instances to XML for HMRC. If the `xml_name` has been set then
    # it will be used, otherwise the class name will be used as a default.
    #
    # Returns a String
    def self.xml_name
      @xml_name || name.demodulize
    end

    # Internal: provides access to the formats hash, falling back on an empty
    # hash by default. These formats are used by the date and monetary nodes
    # for converting their values to strings HMRC will accept.
    #
    # Returns a Hash
    def self.formats
      @formats ||= {}
    end

    # Internal: provides access to the hash of nodes where the default for an
    # unspecified key is an empty array. This stores the nodes as they are
    # created with the key being the name of the node (which is the name of the
    # method called to set it) and the value being an array of all the values
    # set on this node in the order they are set.
    #
    # Returns a Hash
    def nodes
      @nodes ||= Hash.new { |h, k| h[k] = [] }
    end

    private

    # Private: a convenience method for getting the format string for a given
    # key.
    #
    # Returns a format String
    # Raises a KeyError if the requested format is not found
    def format_for(type)
      self.class.formats.fetch(type)
    end
  end
end
