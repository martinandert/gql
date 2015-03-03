module GQL
  class Executor
    def initialize(ast_root)
      @ast_root = ast_root
      @variables = ast_root.variables
    end

    def execute(context = {})
      root_class = Schema.root

      raise Errors::UndefinedRoot if root_class.nil?
      raise Errors::InvalidNodeClass.new(root_class, Node) unless root_class < Node

      root = root_class.new(@ast_root, nil, @variables, context)
      root.__value
    end
  end
end
