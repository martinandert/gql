module GQL
  module Schema
    class Node < GQL::Node
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
