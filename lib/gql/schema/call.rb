module GQL
  module Schema
    class Call < GQL::Node
      cursor :id

      string  :id
      string  :type,         -> { target.name }
      object  :result_class, -> { target.result_class || Placeholder }, node_class: Node
      array   :parameters,   -> { (target.proc || target.instance_method(:execute)).parameters }, item_class: Parameter
    end
  end
end
