# Copyright 2014 FreeAgent Central Ltd.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'bigdecimal'
require 'active_support'
require 'active_support/core_ext/string/inflections'
require 'active_support/core_ext/object/blank'

require 'hermod/xml_node'

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
    # symbolic_name - the name of the node. This will become the name of the
    #                 method on the XmlSection.
    # options       - a hash of options used to set up validations.
    #
    # Returns nothing you should rely on
    def string_node(symbolic_name, options={})
      raise DuplicateNodeError, "#{symbolic_name} is already defined" if @node_order.include? symbolic_name
      @node_order << symbolic_name

      xml_name = options.fetch(:xml_name, symbolic_name.to_s.camelize)

      @new_class.send :define_method, symbolic_name do |value, attributes={}|
        if options.has_key?(:input_mutator)
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

    # Public: defines a node for sending an integer to HMRC
    #
    # symbolic_name - the name of the node. This will become the name of the
    #                 method on the XmlSection.
    # options       - a hash of options used to set up validations.
    #
    # Returns nothing you should rely on
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
