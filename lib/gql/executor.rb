module GQL
  class Executor
    def initialize(ast_root)
      @ast_node   = ast_root.node
      @variables  = ast_root.variables
    end

    def execute(context = {})
      node_class = GQL.root_node_class

      raise Errors::UndefinedRoot if node_class.nil?

      node = node_class.new(@ast_node, nil, @variables, context)
      node.__value
    end
  end
end
