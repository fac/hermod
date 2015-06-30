module Hermod
  class InputMutator
    attr_reader :mutator_proc

    def initialize(mutator_proc)
      @mutator_proc = mutator_proc
    end

    def mutate!(values, attributes, instance)
      if mutator_proc.arity == 2
        mutator_proc.call(values, attributes)
      else
        mutator_proc.call(values, attributes, instance)
      end
    end
  end
end
