require 'active_support/core_ext/class/attribute'

module GQL
  class Array < Field
    class_attribute :item_field_class, instance_accessor: false, instance_predicate: false

    class << self
      def build_class(id, proc, options = {})
        item_field_class = options.delete(:item_field_class) || self.item_field_class
        item_field_class = ::Hash.new(item_field_class) unless item_field_class.is_a?(::Hash)

        Class.new(self).tap do |field_class|
          field_class.id = id.to_s
          field_class.proc = proc
          field_class.item_field_class = item_field_class
        end
      end
    end

    def value
      target.map do |item|
        field_class = Registry.fetch(self.class.item_field_class[item.class])

        field = field_class.new(ast_node, item, variables, context)
        field.value
      end
    end
  end
end
