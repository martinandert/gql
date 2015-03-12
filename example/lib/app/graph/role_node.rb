module App
  module Graph
    class RoleNode < ModelNode
      connection :members, item_class: PersonNode

      def scalar_value
        target.name
      end
    end
  end
end
