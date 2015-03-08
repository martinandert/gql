require 'active_support/core_ext/class/attribute'

module GQL
  class Connection < Node
    class << self
      def build_class(id, proc, options = {})
        list_class = options.delete(:list_class) || GQL.default_list_class
        item_class = options.delete(:item_class)

        Node.validate_is_subclass! list_class, 'list'

        list_class.build_class(id, proc, options).tap do |field_class|
          field_class.array :edges, -> { target }, item_class: item_class
        end
      end
    end
  end
end
