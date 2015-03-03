module GQL
  class Call
    attr_reader :target, :context

    def initialize(caller, ast_node, target, variables, context)
      @caller, @ast_node, @target = caller, ast_node, target
      @variables, @context = variables, context
    end

    def execute
      args = substitute_variables(@ast_node.arguments)
      target = instance_exec(*args, &self.class.const_get(:Function))

      result_class = self.class.const_get(:Result) || @caller.class

      result = result_class.new(@ast_node, target, @variables, context)
      result.__value
    end

    private
      def substitute_variables(args)
        args.map { |arg| arg.is_a?(Symbol) ? @variables[arg] : arg }
      end
  end
end
