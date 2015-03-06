module GQL
  class Root < Object
    def value
      if ast_node.respond_to? :arguments
        value_of_call
      else
        super
      end
    end

    private
      def value_of_call
        call_class = self.class.calls[ast_node.id]

        if call_class.nil?
          raise Errors::UndefinedCall.new(ast_node.id, self.class)
        end

        call = call_class.new(self, ast_node, target, variables, context)
        call.value
      end
  end
end
