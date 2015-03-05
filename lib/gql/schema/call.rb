module GQL
  module Schema
    class Call < GQL::Node
      cursor :id
      string :id

      array :parameters, :item_class => Parameter do
        target.method.parameters
      end

      string :type do
        target.name
      end

      object :result_class, :node_class => Node do
        target.result_class || Placeholder
      end
    end
  end
end
