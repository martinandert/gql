module GQL
  module Fields
    class Object < Field
      def __value
        raise Errors::InvalidNodeClass.new(__node_class__, Node) unless __node_class__ < Node

        node = __node_class__.new(@ast_node, __target, @variables, __context)
        node.__value
      end

      private
        def __node_class__
          self.class.const_get :NODE_CLASS
        end
    end
  end
end
