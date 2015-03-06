module GQL
  module Schema
    class Call < GQL::Node
      cursor :id

      string  :id
      string  :type,         -> { target.name }
      array   :parameters,   -> { target.method.parameters }, item_class: Parameter
      object  :result_class, -> { target.result_class || Placeholder }, node_class: Node
    end
  end
end
