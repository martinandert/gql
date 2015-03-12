module App
  module Graph
    class RoleField < ModelField
      connection :members, item_field_class: PersonField
    end
  end
end
