require 'active_support/core_ext/object/try'

module GQL
  module Schema
    class Call < GQL::Field
      cursor :id

      string  :id
      string  :name
      object  :result_class, -> { target.result_class || CallerClass }, object_class: Field
      array   :parameters,   -> { target.parameters }, item_class: Parameter

      def scalar_value
        target.name
      end
    end
  end
end
