require 'active_support/core_ext/class/attribute'

module GQL
  class Array < Field
    class_attribute :item_class, instance_writer: false, instance_predicate: false

    class << self
      def build_class(id, method, options = {})
        item_class = options[:item_class] || self.item_class

        validate_is_subclass_of! item_class, Node, 'item'

        Class.new(self).tap do |field_class|
          field_class.id = id.to_s
          field_class.method = method
          field_class.item_class = item_class
        end
      end
    end

    call :size, Number, -> { target.size }

    def value
      target.map do |item|
        node = item_class.new(ast_node, item, variables, context)
        node.value
      end
    end
  end
end
