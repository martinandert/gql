module App
  module Graph
    class RoleField < ModelField
      connection :members, item_field_class: PersonField

      def scalar_value
        target.name
      end
    end
  end
end
