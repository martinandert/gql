require 'active_support/core_ext/class/attribute'

module GQL
  class Call
    class_attribute :id, :result_class, :proc, instance_accessor: false, instance_predicate: false

    class << self
      def returns(result_class = nil, &block)
        self.result_class = result_class || result_class_from_block(block)
      end

      def execute(caller_class, ast_node, target, variables, context)
        args = substitute_variables(ast_node.arguments, variables.dup)
        target = new(target, context).execute(*args)

        next_class = result_class || caller_class

        result = next_class.new(ast_node, target, variables, context)
        result.value
      end

      private
        def substitute_variables(args, variables)
          args.map { |arg| substitute_variable arg, variables }
        end

        def substitute_variable(arg, variables)
          return arg unless arg.is_a?(::Symbol)
          return variables[arg] if variables.has_key?(arg)

          raise Errors::VariableNotFound, arg
        end

        def result_class_from_block(block)
          Class.new(Node).tap do |result_class|
            result_class.field_proc = -> id { -> { target[id] } }
            result_class.class_eval(&block)
          end
        end
    end

    attr_reader :target, :context

    def initialize(target, context)
      @target, @context = target, context
    end

    def execute(*)
      raise NotImplementedError, 'override in subclass'
    end
  end
end
