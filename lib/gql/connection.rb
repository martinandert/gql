require 'active_support/core_ext/class/attribute'

module GQL
  class Connection < Field
    class << self
      def build_class(id, proc, options = {})
        list_field_class = options.delete(:list_field_class) || GQL.default_list_field_class
        item_field_class = options.delete(:item_field_class)

        Field.validate_is_subclass! list_field_class, 'list_field_class'

        list_field_class.build_class(id, proc, options).tap do |field_class|
          field_class.array :edges, -> { target }, item_field_class: item_field_class
        end
      end
    end
  end
end
