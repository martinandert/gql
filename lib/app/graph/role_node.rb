module App
  module Graph
    class RoleNode < ModelNode
      connection :members, item_class: PersonNode
    end
  end
end
