require 'active_support/core_ext/class/attribute'

module GQL
  class Connection < Field
    class_attribute :list_class, instance_accessor: false, instance_predicate: false
    class_attribute :item_class, instance_accessor: false, instance_predicate: false

    class << self
      def build_class(id, method, options = {})
        list_class = options[:list_class] || self.list_class || GQL.default_list_class
        item_class = options[:item_class] || self.item_class

        validate_is_subclass_of! list_class, Connection, 'list'
        validate_is_subclass_of! item_class, Node, 'item'

        Class.new(list_class).tap do |field_class|
          field_class.id = id.to_s
          field_class.method = method

          field_class.array :edges, item_class: item_class do
            target
          end
        end
      end
    end
  end
end
