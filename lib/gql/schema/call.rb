module GQL
  module Schema
    class Call < GQL::Node
      cursor :id

      string  :id
      string  :name
      object  :result_class, -> { target.result_class || Placeholder }, node_class: Root
      array   :parameters,   -> { (target.proc || target.instance_method(:execute)).parameters }, item_class: Parameter

      def raw_value
        target.name
      end
    end
  end
end
