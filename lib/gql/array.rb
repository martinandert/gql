require 'active_support/core_ext/class/attribute'

module GQL
  class Array < Field
    class_attribute :item_class, instance_accessor: false, instance_predicate: false

    class << self
      def build_class(id, proc, options = {})
        item_class = options.delete(:item_class) || self.item_class
        item_class = Object.build_class(:item, -> { target }, object_class: item_class)

        Class.new(self).tap do |field_class|
          field_class.id = id
          field_class.proc = proc
          field_class.item_class = item_class

          if item_class && item_class.name.nil?
            field_class.const_set :Item, item_class
          end
        end
      end
    end

    def value
      target.map do |item|
        field = self.class.item_class.new(ast_node, item, variables, context)
        field.value
      end
    end
  end
end
