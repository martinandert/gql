module GQL
  module Schema
    class Call < GQL::Object
      cursor :id
      string :id

      string :type, -> { target.name }

      array :parameters, -> { target.target_method.parameters }, item_class: Parameter

      object :result_class, -> { target.result_class || Placeholder }, node_class: Node
    end
  end
end
