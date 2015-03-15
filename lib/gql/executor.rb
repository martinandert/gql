module GQL
  class Executor
    class Context < Struct.new(:target, :context, :field_class)
      def execute(method, args = [])
        instance_exec(*args, &method)
      end
    end

    attr_reader :ast_root, :variables

    def initialize(ast_query)
      @ast_root   = ast_query.root
      @variables  = ast_query.variables
    end

    def execute(context = {}, vars = {})
      raise Errors::RootClassNotSet unless GQL.root_class

      root_class = Registry.fetch(GQL.root_class)
      root_class.id = ast_root.id
      root_class.proc = GQL.root_target_proc
      root_class.execute self.class, ast_root, nil, variables.merge(vars), context
    end
  end
end
