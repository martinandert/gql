require 'active_support/core_ext/class/attribute'

module GQL
  class Connection < Object
    class_attribute :list_class, instance_writer: false, instance_predicate: false
    class_attribute :item_class, instance_writer: false, instance_predicate: false

    class << self
      alias_method :original_build_class, :build_class

      def build_class(id, options = {})
        list_class = options.delete(:list_class) || self.list_class || GQL.default_list_class
        item_class = options.delete(:item_class) || self.item_class

        Connection.validate_is_subclass! list_class, 'list'
        Field.validate_is_subclass! item_class, 'item'

        Class.new(list_class).tap do |field_class|
          field_class.id = id.to_s
          field_class.array :edges, -> { target }, item_class: item_class
        end
      end
    end
  end
end
