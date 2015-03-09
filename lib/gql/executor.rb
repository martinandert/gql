module GQL
  class Executor
    attr_reader :ast_root, :variables

    def initialize(ast_query)
      @ast_root   = ast_query.root
      @variables  = ast_query.variables
    end

    def execute(context = {})
      node_class = GQL.root_node_class

      raise Errors::UndefinedRoot if node_class.nil?

      context[:_schema_root] = node_class if ENV['DEBUG']

      target = GQL.root_target_proc.call(context)

      node = node_class.new(ast_root, target, variables, context)
      node.value
    end
  end
end
