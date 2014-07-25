require 'bigdecimal'
require 'active_support'
require 'active_support/core_ext/string/inflections'
require 'active_support/core_ext/object/blank'

require 'hmrc/gov_talk/xml_node'

module HMRC
  module GovTalk
    XmlError = Class.new(StandardError)
    InvalidInputError = Class.new(XmlError)
    DuplicateNodeError = Class.new(XmlError)

    class XmlSectionBuilder

      ZERO = BigDecimal.new('0').freeze
      BOOLEAN_VALUES = [
        YES = "yes".freeze,
        NO  = "no".freeze,
      ]

      def initialize(new_class)
        @new_class = new_class
        @node_order = []
      end

      def build(&block)
        yield self
        @new_class.node_order = @node_order
        @new_class
      end

      def string_node(symbolic_name, options={})
        raise DuplicateNodeError, "#{symbolic_name} is already defined" if @node_order.include? symbolic_name
        @node_order << symbolic_name

        xml_name = options.fetch(:xml_name, symbolic_name.to_s.camelize)

        @new_class.send :define_method, symbolic_name do |value, attributes={}|
          if options.has_key? :input_mutator
            value, attributes = options[:input_mutator].call(value, attributes)
          end
          if value.blank?
            if options[:optional]
              return # Don't need to add an empty node
            else
              raise InvalidInputError, "#{symbolic_name} isn't optional but no value was provided"
            end
          end
          if options.has_key?(:allowed_values) && !options[:allowed_values].include?(value)
            raise InvalidInputError,
              "#{value.inspect} is not in the list of allowed values for #{symbolic_name}: #{options[:allowed_values].inspect}"
          end
          if options.has_key?(:matches) && value !~ options[:matches]
            raise InvalidInputError,
              "Value #{value.inspect} for #{symbolic_name} doesn't match #{options[:matches].inspect}"
          end
          nodes[symbolic_name] << XmlNode.new(xml_name, value.to_s, attributes).rename_attributes(options[:attributes])
        end
      end

      def integer_node(symbolic_name, options={})
        raise DuplicateNodeError, "#{symbolic_name} is already defined" if @node_order.include? symbolic_name
        @node_order << symbolic_name

        xml_name = options.fetch(:xml_name, symbolic_name.to_s.camelize)

        @new_class.send :define_method, symbolic_name do |value, attributes={}|
          if options.has_key?(:range) && (options[:range][:min] > value || options[:range][:max] < value)
            raise InvalidInputError,
              "#{value} is outwith the allowable range for #{symbolic_name}: #{options[:range][:min]} - #{options[:range][:max]}"
          end
          nodes[symbolic_name] << XmlNode.new(xml_name, value.to_s, attributes).rename_attributes(options[:attributes]) if value.present?
        end
      end

      def date_node(symbolic_name, options={})
        raise DuplicateNodeError, "#{symbolic_name} is already defined" if @node_order.include? symbolic_name
        @node_order << symbolic_name

        xml_name = options.fetch(:xml_name, symbolic_name.to_s.camelize)

        @new_class.send :define_method, symbolic_name do |value, attributes={}|
          if value.blank?
            if options[:optional]
              return # Don't need to add an empty node
            else
              raise InvalidInputError, "#{symbolic_name} isn't optional but no value was provided"
            end
          end
          unless value.respond_to?(:strftime)
            raise InvalidInputError, "#{symbolic_name} must be set to a date"
          end
          nodes[symbolic_name] << XmlNode.new(xml_name, value.strftime(format_for(:date)), attributes).rename_attributes(options[:attributes])
        end
      end

      def yes_node(symbolic_name, options={})
        raise DuplicateNodeError, "#{symbolic_name} is already defined" if @node_order.include? symbolic_name
        @node_order << symbolic_name

        xml_name = options.fetch(:xml_name, symbolic_name.to_s.camelize)

        @new_class.send :define_method, symbolic_name do |value, attributes={}|
          if value
            nodes[symbolic_name] << XmlNode.new(xml_name, YES, attributes).rename_attributes(options[:attributes]) if value.present?
          end
        end
      end

      def yes_no_node(symbolic_name, options={})
        raise DuplicateNodeError, "#{symbolic_name} is already defined" if @node_order.include? symbolic_name
        @node_order << symbolic_name

        xml_name = options.fetch(:xml_name, symbolic_name.to_s.camelize)

        @new_class.send :define_method, symbolic_name do |value, attributes={}|
          nodes[symbolic_name] << XmlNode.new(xml_name, value ? YES : NO, attributes).rename_attributes(options[:attributes])
        end
      end

      def monetary_node(symbolic_name, options={})
        raise DuplicateNodeError, "#{symbolic_name} is already defined" if @node_order.include? symbolic_name
        @node_order << symbolic_name

        xml_name = options.fetch(:xml_name, symbolic_name.to_s.camelize)

        @new_class.send :define_method, symbolic_name do |value, attributes={}|
          value ||= 0 # nils are zero
          if !options.fetch(:negative, true) && value < ZERO
            raise InvalidInputError, "#{symbolic_name} cannot be negative"
          end
          # Don't allow fractional values for whole number nodes
          if options[:whole_units] && value != value.to_i
            raise InvalidInputError, "#{symbolic_name} must be in whole pounds"
          end
          # Don't include optional nodes if they're zero
          if !(options[:optional] && value.zero?)
            nodes[symbolic_name] << XmlNode.new(xml_name, sprintf(format_for(:money), value), attributes).rename_attributes(options[:attributes]) if value.present?
          end
        end
      end

      def parent_node(symbolic_name, options={})
        raise DuplicateNodeError, "#{symbolic_name} is already defined" if @node_order.include? symbolic_name
        @node_order << symbolic_name

        xml_name = options.fetch(:xml_name, symbolic_name.to_s.camelize)

        @new_class.send :define_method, symbolic_name do |value, attributes={}|
          nodes[symbolic_name] << XmlNode.new(xml_name, value, attributes).rename_attributes(options[:attributes]) if value.present?
        end
      end
    end
  end
end
