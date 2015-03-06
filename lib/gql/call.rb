module GQL
  class Call
    class_attribute :id, :result_class, :method, instance_accessor: false, instance_predicate: false

    class << self
      def build_class(id, result_class, method)
        if result_class.is_a? ::Array
          if result_class.size == 1
            result_class.unshift GQL.default_list_class || Connection
          end

          options = {
            list_class: result_class.first,
            item_class: result_class.last
          }

          result_class = Connection.build_class(:result, nil, options)
        elsif result_class
          Node.validate_is_subclass_of! result_class, Node, 'result'
        end

        Class.new(self).tap do |call_class|
          call_class.id = id.to_s
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

      method = Node::ExecutionContext.new(target, context)
      target = method.execute(self.class.method, args)
      result_class = self.class.result_class || caller.class

      result = result_class.new(ast_node, target, variables, context)
      result.value
    end

    private
      def substitute_variables(args)
        args.map { |arg| arg.is_a?(::Symbol) ? variables[arg] : arg }
      end
  end
end
