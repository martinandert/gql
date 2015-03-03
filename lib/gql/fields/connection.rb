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
        raise Errors::InvalidNodeClass.new(__connection_class__, GQL::Connection) unless __connection_class__ < GQL::Connection

        connection = __connection_class__.new(__node_class__, @ast_node, __target, @variables, __context)
        connection.__value
      end

      private
        def __connection_class__
          self.class.const_get :CONNECTION_CLASS
        end

        def __node_class__
          self.class.const_get :NODE_CLASS
        end
    end
  end
end
