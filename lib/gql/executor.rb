module GQL
  class Executor
    attr_reader :ast_node, :variables

    def initialize(ast_root)
      @ast_node   = ast_root.node
      @variables  = ast_root.variables
    end

    def execute(context = {})
      root_class = GQL.root_node_class

      raise Errors::UndefinedRoot if root_class.nil?

      context[:_schema_root] = root_class if ENV['DEBUG']

      root = root_class.new(ast_node, nil, variables, context)
      root.value
    end
  end
end
