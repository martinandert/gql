module GQL
  class Call
    class Method
      attr_reader :target, :context

      def initialize(target, context)
        @target, @context = target, context
      end

      def execute(method, args)
        instance_exec(*args, &method)
      end
    end

    class_attribute :method, :result_class, instance_accessor: false, instance_predicate: false

    class << self
      def build_class(result_class, method)
        if result_class.is_a? Array
          result_class.unshift Connection if result_class.size == 1
          result_class.unshift Fields::Connection if result_class.size == 2

          field_type_class, connection_class, node_class = result_class

          raise Errors::InvalidNodeClass.new(field_type_class, Fields::Connection) unless field_type_class <= Fields::Connection

          result_class = field_type_class.build_class(nil, connection_class, node_class)
        elsif result_class
          raise Errors::InvalidNodeClass.new(result_class, Node) unless result_class <= Node
        end

        Class.new(self).tap do |call_class|
          call_class.method = method
          call_class.result_class = result_class
        end
      end
    end

    attr_reader :caller, :ast_node, :target, :variables, :context

    def initialize(caller, ast_node, target, variables, context)
      @caller, @ast_node, @target = caller, ast_node, target
      @variables, @context = variables, context
    end

    def execute
      args = substitute_variables(ast_node.arguments)

      method = Method.new(target, context)
      target = method.execute(self.class.method, args)
      result_class = self.class.result_class || caller.class

      result = result_class.new(ast_node, target, variables, context)
      result.value
    end

    private
      def substitute_variables(args)
        args.map { |arg| arg.is_a?(Symbol) ? variables[arg] : arg }
      end
  end
end
