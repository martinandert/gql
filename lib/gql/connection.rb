module GQL
  class Connection < Field
    class << self
      def build_class(id, proc, options = {})
        list_field_class = options.delete(:list_field_class) || GQL.default_list_field_class
        item_field_class = options.delete(:item_field_class)

        Registry.fetch(list_field_class).build_class(id, proc, options).tap do |field_class|
          field_class.array :edges, -> { target }, item_field_class: item_field_class
        end
      end
    end
  end
end
