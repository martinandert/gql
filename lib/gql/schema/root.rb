module GQL
  module Schema
    class Root < GQL::Node
      string      :type,   -> { target.name }
      connection  :calls,  -> { target.calls.values  }, list_class: List, item_class: Call
      connection  :fields, -> { target.fields.values }, list_class: List, item_class: Field
    end
  end
end
