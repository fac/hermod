require 'xml'
require 'hmrc/gov_talk/xml_section_builder'
require 'hmrc/gov_talk/sanitisation'

module HMRC
  module GovTalk
    # A representation of a section of XML from an SA submission.
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

      def self.xml_name
        @xml_name || name.demodulize
      end

      def self.formats
        @formats ||= {}
      end

      def nodes
        @nodes ||= Hash.new { |h, k| h[k] = [] }
      end

      def to_xml
        XML::Node.new(self.class.xml_name).tap do |root_node|
          # Add attributes
          attributes.each do |attribute_name, attribute_value|
            sane_value = sanitize_attribute(attribute_value)
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

      private

      def format_for(type)
        self.class.formats.fetch(type)
      end
    end
  end
end
