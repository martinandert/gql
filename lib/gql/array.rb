require 'active_support/core_ext/class/attribute'

module GQL
  class Array < Field
    class_attribute :item_field_class, instance_accessor: false, instance_predicate: false

    class << self
      def build_class(id, proc, options = {})
        item_field_class = options.delete(:item_field_class) || self.item_field_class

        if item_field_class.is_a?(Hash)
          item_field_class.values.each do |ifc|
            Field.validate_is_subclass! ifc, 'item_field_class'
          end
        else
          Field.validate_is_subclass! item_field_class, 'item_field_class'
          item_field_class = Hash.new(item_field_class)
        end

        Class.new(self).tap do |field_class|
          field_class.id = id.to_s
          field_class.proc = proc
          field_class.item_field_class = item_field_class
        end
      end
    end

    def value
      target.map do |item|
        field = self.class.item_field_class[item.class].new(ast_node, item, variables, context)
        field.value
      end
    end
  end
end
