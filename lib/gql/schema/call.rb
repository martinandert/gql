module GQL
  module Schema
    class Call < GQL::Field
      cursor :id

      string  :id
      string  :name
      object  :result_class, -> { target.result_class || CallerClass }, class: Field
      array   :parameters,   -> { (target.proc || target.instance_method(:execute)).parameters }, item_class: Parameter

      def scalar_value
        target.name
      end
    end
  end
end
