require 'active_support/core_ext/class/attribute'

module GQL
  class Call
    class_attribute :result_class, :proc, instance_accessor: false, instance_predicate: false

    class << self
      def returns(result_class)
        self.result_class = result_class
      end
    end

    attr_reader :target, :context

    def initialize(target, context)
      @target, @context = target, context
    end

    def execute(*)
      raise NotImplementedError, 'override in subclass'
    end

    def result_for(caller_class, ast_node, variables)
      args = substitute_variables(ast_node.arguments, variables)
      target = execute(*args)

      result_class = self.class.result_class || caller_class

      result = result_class.new(ast_node, target, variables, context)
      result.value
    end

    private
      def substitute_variables(args, variables)
        args.map { |arg| arg.is_a?(::Symbol) ? variables[arg] : arg }
      end
  end
end
