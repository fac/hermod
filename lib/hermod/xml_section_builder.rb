require 'bigdecimal'
require 'active_support'
require 'active_support/core_ext/string/inflections'
require 'active_support/core_ext/object/blank'

require 'hermod/xml_node'
require 'hermod/input_mutator'
require 'hermod/validators/allowed_values'
require 'hermod/validators/attributes'
require 'hermod/validators/range'
require 'hermod/validators/regular_expression'
require 'hermod/validators/value_presence'

module Hermod

  # Internal: the base class from which all Hermod errors inherit
  XmlError = Class.new(StandardError)

  # Public: the error that's raised whenever some validation or constraint
  # specified on a node fails.
  InvalidInputError = Class.new(XmlError)

  # Public: the error that's raised when you try to define two nodes with the
  # same name when building an XmlSection.
  DuplicateNodeError = Class.new(XmlError)

  # Public: Used to build an anonymous subclass of XmlSection with methods for
  # defining nodes on that subclass of varying types used by HMRC.
  class XmlSectionBuilder

    ZERO = BigDecimal.new('0').freeze
    BOOLEAN_VALUES = [
      YES = "yes".freeze,
      NO  = "no".freeze,
    ]

    # Internal: Sets up the builder with the anonymous subclass of XmlSection.
    # Don't use this directly, instead see `Hermod::XmlSection.build`
    def initialize(new_class)
      @new_class = new_class
      @node_order = []
    end

    # Internal: Takes a block to build the class using the methods on this
    # builder and then sets the correct node_order (to ensure the nodes are
    # ordered correctly in the XML).
    #
    # Returns the newly built class. This should be assigned to a constant
    # before use.
    def build(&block)
      yield self
      @new_class.node_order = @node_order
      @new_class
    end

    def create_method(name, mutators, validators, options = {}, &block)
      raise DuplicateNodeError, "#{name} is already defined" if @node_order.include? name
      @node_order << name
      xml_name = options.fetch(:xml_name, name.to_s.camelize)

      @new_class.send :define_method, name do |value, attributes = {}|
        mutators.each { |mutator| value, attributes = mutator.mutate!(value, attributes) }
        begin
          validators.each { |validator| validator.valid?(value, attributes) }
        rescue InvalidInputError => ex
          raise InvalidInputError, "#{name} #{ex.message}"
        end

        value, attributes = block.call(value, attributes)
        nodes[name] << XmlNode.new(xml_name, value.to_s, attributes).rename_attributes(options[:attributes])
      end
    end

    # Public: defines a node for sending a string to HMRC
    #
    # name    - the name of the node. This will become the name of the method
    #           on the XmlSection.
    # options - a hash of options used to set up validations.
    #
    # Returns nothing you should rely on
    def string_node(name, options={})
      mutators = [].tap do |mutators|
        mutators << InputMutator.new(options.delete(:input_mutator)) if options.has_key? :input_mutator
      end
      validators = [].tap do |validators|
        validators << Validators::AllowedValues.new(options.delete(:allowed_values)) if options.has_key? :allowed_values
        validators << Validators::RegularExpression.new(options.delete(:matches)) if options.has_key? :matches
        validators << Validators::ValuePresence.new unless options.delete(:optional)
        validators << Validators::Attributes.new(options.fetch(:attributes, {}).keys)
      end
      create_method(name, mutators, validators, options) do |value, attributes|
        [value, attributes]
      end
    end

    # Public: defines a node for sending an integer to HMRC
    #
    # name    - the name of the node. This will become the name of the method
    #           on the XmlSection.
    # options - a hash of options used to set up validations.
    #
    # Returns nothing you should rely on
    def integer_node(name, options={})
      validators = [].tap do |validators|
        if options.has_key? :range
          validators << Validators::Range.new(options[:range][:min], options[:range][:max])
        end
      end
      create_method(name, [], validators, options) do |value, attributes|
        [value, attributes]
      end
    end

    # Public: defines a node for sending a date to HMRC
    #
    # symbolic_name - the name of the node. This will become the name of the
    #                 method on the XmlSection.
    # options       - a hash of options used to set up validations.
    #
    # Returns nothing you should rely on
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

    # Public: defines a node for sending a boolean to HMRC. It will only be
    # sent if the boolean is true.
    #
    # symbolic_name - the name of the node. This will become the name of the
    #                 method on the XmlSection.
    # options       - a hash of options used to set up validations.
    #
    # Returns nothing you should rely on
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

    # Public: defines a node for sending a boolean to HMRC. A "yes" will be
    # sent if it's true and a "no" will be sent if it's false
    #
    # symbolic_name - the name of the node. This will become the name of the
    #                 method on the XmlSection.
    # options       - a hash of options used to set up validations.
    #
    # Returns nothing you should rely on
    def yes_no_node(symbolic_name, options={})
      raise DuplicateNodeError, "#{symbolic_name} is already defined" if @node_order.include? symbolic_name
      @node_order << symbolic_name

      xml_name = options.fetch(:xml_name, symbolic_name.to_s.camelize)

      @new_class.send :define_method, symbolic_name do |value, attributes={}|
        nodes[symbolic_name] << XmlNode.new(xml_name, value ? YES : NO, attributes).rename_attributes(options[:attributes])
      end
    end

    # Public: defines a node for sending a monetary value to HMRC
    #
    # symbolic_name - the name of the node. This will become the name of the
    #                 method on the XmlSection.
    # options       - a hash of options used to set up validations.
    #
    # Returns nothing you should rely on
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

    # Public: defines an XML parent node that wraps other nodes
    #
    # symbolic_name - the name of the node. This will become the name of the
    #                 method on the XmlSection.
    # options       - a hash of options used to set up validations.
    #
    # Returns nothing you should rely on
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
