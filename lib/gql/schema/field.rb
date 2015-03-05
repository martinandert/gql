module GQL
  module Schema
    class Field < GQL::Node
      cursor :id
      string :id

      string :type do
        target.name
      end

      connection :calls, :list_class => List, :item_class => Call do
        target.calls.values
      end

      connection :fields, :list_class => List, :item_class => Field do
        target.fields.values
      end
    end
  end
end
