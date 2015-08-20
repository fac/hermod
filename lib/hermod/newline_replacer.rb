module Hermod
  class NewlineReplacer
    attr_reader :replacement

    DEFAULT_REPLACEMENT = "  "

    # Public: sets up the mutator with the replacement character. By default
    # two spaces are used.
    def initialize(repl = DEFAULT_REPLACEMENT)
      @replacement = (repl.is_a?(String) ? repl : DEFAULT_REPLACEMENT)
    end

    # Public: changes the value passed in so all newlines are replaced with the
    # replacement character set up when this was initialised (or two spaces if
    # no replacement was provided). Attributes remain unchanged.
    #
    # value - the value of the XML node
    # attributes - the attributes of the XML node as a Hash
    #
    # Returns the new value and attributes as an Array.
    def mutate!(value, attributes)
      [value.gsub(/[\n\r]/, replacement), attributes]
    end
  end
end
