require 'active_support/core_ext/class/attribute'

module GQL
  class Array < Node
    class_attribute :item_class, instance_accessor: false, instance_predicate: false

    class << self
      def build_class(id, proc, options = {})
        item_class = options.delete(:item_class) || self.item_class

        if item_class.is_a?(Hash)
          item_class.values.each do |klass|
            Node.validate_is_subclass! klass, 'item'
          end
        else
          Node.validate_is_subclass! item_class, 'item'
          item_class = Hash.new(item_class)
        end

        Class.new(self).tap do |field_class|
          field_class.id = id.to_s
          field_class.proc = proc
          field_class.item_class = item_class
        end
      end
    end

    def value
      target.map do |item|
        node = self.class.item_class[item.class].new(ast_node, item, variables, context)
        node.value
      end
    end
  end
end
