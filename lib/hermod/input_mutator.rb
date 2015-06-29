module Hermod
  class InputMutator
    attr_reader :mutator_proc

    def initialize(mutator_proc)
      @mutator_proc = mutator_proc
    end

    def mutate!(values, attributes, instance)
      mutator_proc.call(values, attributes, instance)
    end
  end
end
