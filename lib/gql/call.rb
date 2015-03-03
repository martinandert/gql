module GQL
  class Call
    attr_reader :target, :context

    def initialize(caller, ast_node, target, definition, variables, context)
      @caller, @ast_node, @target = caller, ast_node, target
      @definition, @variables, @context = definition, variables, context
    end

    def execute
      args = @ast_node.arguments.map { |arg| arg.is_a?(Symbol) ? @variables[arg] : arg }
      target = instance_exec(*args, &@definition[:body])

      node_class = @definition[:returns] || @caller.class

      raise Errors::InvalidNodeClass.new(node_class, Node) unless node_class < Node

      node = node_class.new(@ast_node, target, @variables, context)
      node.__value
    end
  end
end
