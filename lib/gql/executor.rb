module GQL
  class Executor
    attr_reader :ast_root, :variables

    def initialize(ast_query)
      @ast_root   = ast_query.root
      @variables  = ast_query.variables
    end

    def execute(context = {}, vars = {})
      field_class = GQL.root_class

      raise Errors::RootClassNotSet if field_class.nil?

      variables.update vars

      target = GQL.root_target_proc.call(context)

      field = Registry.fetch(field_class).new(ast_root, target, variables, context)
      field.value
    end
  end
end
