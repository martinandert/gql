module GQL
  module Schema
    class Field < GQL::Field
      cursor :id

      string      :id
      string      :name
      connection  :calls,  -> { target.calls.values  }, list_class: List, item_class: Call
      connection  :fields, -> { target.fields.values }, list_class: List, item_class: Field

      def scalar_value
        target.name
      end
    end
  end
end
