module GQL
  module Fields
    class Connection < Field
      def __value
        if @ast_node.fields
          __raw_value
        else
          super
        end
      end

      def __raw_value
        connection_class = self.class.const_get(:CONNECTION_CLASS)
        node_class = self.class.const_get(:NODE_CLASS)

        raise Errors::InvalidNodeClass.new(connection_class, GQL::Connection) unless connection_class <= GQL::Connection

        connection = connection_class.new(node_class, @ast_node, __target, @variables, __context)
        connection.__value
      end
    end
  end
end
