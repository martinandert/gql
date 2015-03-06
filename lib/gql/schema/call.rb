module GQL
  module Schema
    class Call < GQL::Node
      cursor :id

      string  :id
      string  :type,         -> { target.name }
      object  :result_class, -> { target.result_class || Placeholder }, node_class: Node


      array :parameters, -> {
        if target.proc
          target.proc.parameters
        else
          target.instance_method(:execute).parameters
        end
      }, item_class: Parameter
    end
  end
end
