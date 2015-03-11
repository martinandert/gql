module App
  module Graph
    class RoleNode < ModelNode
      connection :members, item_class: PersonNode

      def raw_value
        target.name
      end
    end
  end
end
