require 'active_support/core_ext/class/attribute'

module GQL
  class Object < Field
    class << self
      def build_class(id, proc, options = {})
        field_class = options.delete(:field_class)

        Field.validate_is_subclass! field_class, 'field_class'

        field_class.build_class id, proc, options
      end
    end
  end
end
