module GQL
  module Schema
    class Field < GQL::Field
      cursor :id

      string      :id
      string      :name
      connection  :calls,  -> { target.calls.values  }, list_field_class: List, item_field_class: Call
      connection  :fields, -> { target.fields.values }, list_field_class: List, item_field_class: Field

      def scalar_value
        target.name
      end
    end
  end
end
