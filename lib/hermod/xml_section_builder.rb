require 'bigdecimal'
require 'active_support'
require 'active_support/core_ext/string/inflections'
require 'active_support/core_ext/object/blank'

require 'hermod/xml_node'
require 'hermod/input_mutator'
require 'hermod/validators/allowed_values'
require 'hermod/validators/attributes'
require 'hermod/validators/type_checker'
require 'hermod/validators/non_negative'
require 'hermod/validators/non_zero'
require 'hermod/validators/range'
require 'hermod/validators/regular_expression'
require 'hermod/validators/value_presence'
require 'hermod/validators/whole_units'

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

    # Public: defines a node for sending a string to HMRC
    #
    # name    - the name of the node. This will become the name of the method on the XmlSection.
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
    # name    - the name of the node. This will become the name of the method on the XmlSection.
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
        [value.to_s, attributes]
      end
    end

    # Public: defines a node for sending a date to HMRC
    #
    # name    - the name of the node. This will become the name of the method on the XmlSection.
    # options - a hash of options used to set up validations.
    #
    # Returns nothing you should rely on
    def date_node(name, options={})
      validators = [].tap do |validators|
        validators << Validators::ValuePresence.new unless options.delete(:optional)
        validators << Validators::TypeChecker.new(Date) { |value| value.respond_to? :strftime }
      end

      create_method(name, [], validators, options) do |value, attributes|
        [(value ? value.strftime(format_for(:date)) : nil), attributes]
      end
    end

    # Public: defines a node for sending a boolean to HMRC. It will only be
    # sent if the boolean is true.
    #
    # name    - the name of the node. This will become the name of the method on the XmlSection.
    # options - a hash of options used to set up validations.
    #
    # Returns nothing you should rely on
    def yes_node(name, options={})
      create_method(name, [], [], options) do |value, attributes|
        [(value ? YES : nil), attributes]
      end
    end

    # Public: defines a node for sending a boolean to HMRC. A "yes" will be
    # sent if it's true and a "no" will be sent if it's false
    #
    # name    - the name of the node. This will become the name of the method on the XmlSection.
    # options - a hash of options used to set up validations.
    #
    # Returns nothing you should rely on
    def yes_no_node(name, options={})
      create_method(name, [], [], options) do |value, attributes|
        [(value ? YES : NO), attributes]
      end
    end

    # Public: defines a node for sending a monetary value to HMRC
    #
    # name    - the name of the node. This will become the name of the method on the XmlSection.
    # options - a hash of options used to set up validations.
    #
    # Returns nothing you should rely on
    def monetary_node(name, options={})
      validators = [].tap do |validators|
        validators << Validators::NonNegative.new unless options.fetch(:negative, true)
        validators << Validators::NonZero.new unless options.fetch(:zero, true)
        validators << Validators::WholeUnits.new if options[:whole_units]
      end

      create_method(name, [], validators, options) do |value, attributes|
        value ||= value.to_i
        if options[:optional] && value == 0
          [nil, attributes]
        else
          [sprintf(format_for(:money), value), attributes]
        end
      end
    end

    # Public: defines an XML parent node that wraps other nodes
    #
    # name    - the name of the node. This will become the name of the method on the XmlSection.
    # options - a hash of options used to set up validations.
    #
    # Returns nothing you should rely on
    def parent_node(name, options={})
      create_method(name, [], [], options) do |value, attributes|
        [value, attributes]
      end
    end

    private

    # Private: creates a method with a given name that uses a set of mutators
    # and a set of validators to change and validate the input according to
    # certain options. This is used to implement all the node type methods.
    #
    # name -       the name of the new method
    # mutators -   an array of InputMutator objects (normally one) that change the value and attributes in some way
    # validators - an array of Validator::Base subclasses that are applied to the value and attributes and raise
    #              errors under given conditions
    # block -      a block that takes the value and attributes and does any post-validation mutation on them
    #
    # Returns nothing you should rely on
    def create_method(name, mutators, validators, options = {}, &block)
      raise DuplicateNodeError, "#{name} is already defined" if @node_order.include? name
      @node_order << name
      xml_name = options.fetch(:xml_name, name.to_s.camelize)

      @new_class.send :define_method, name do |value, attributes = {}|
        mutators.each { |mutator| value, attributes = mutator.mutate!(value, attributes, self) }
        begin
          validators.each { |validator| validator.valid?(value, attributes) }
        rescue InvalidInputError => ex
          raise InvalidInputError, "#{name} #{ex.message}"
        end

        value, attributes = instance_exec(value, attributes, &block)
        if value.present?
          nodes[name] << XmlNode.new(xml_name, value, attributes).rename_attributes(options[:attributes])
        end
      end
    end

  end
end
