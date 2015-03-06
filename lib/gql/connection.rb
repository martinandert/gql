require 'active_support/core_ext/class/attribute'

module GQL
  class Connection < Field
    class_attribute :list_class, instance_accessor: false, instance_predicate: false
    class_attribute :item_class, instance_accessor: false, instance_predicate: false

    class << self
      def build_class(id, proc, options = {})
        list_class = options[:list_class] || self.list_class || GQL.default_list_class
        item_class = options[:item_class] || self.item_class

        Connection.validate_is_subclass! list_class, 'list'
        Node.validate_is_subclass! item_class, 'item'

        Class.new(list_class).tap do |field_class|
          field_class.id = id.to_s
          field_class.proc = proc

          field_class.array :edges, -> { target }, item_class: item_class
        end
      end
    end
  end
end
