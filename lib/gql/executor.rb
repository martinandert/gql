module GQL
  class Executor
    def initialize(ast_root)
      @ast_node   = ast_root.node
      @variables  = ast_root.variables
    end

    def execute(context = {})
      node_class = GQL.root

      raise Errors::UndefinedRoot if node_class.nil?
      raise Errors::InvalidNodeClass.new(node_class, Node) unless node_class < Node

      node = node_class.new(@ast_node, nil, @variables, context)
      node.__value
    end
  end
end
