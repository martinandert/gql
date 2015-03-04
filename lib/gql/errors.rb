require 'active_support/core_ext/array/conversions'

module GQL
  class Error < StandardError
  end

  module Errors
    class UndefinedRoot < Error
      def initialize
        super('Root node class is undefined. Define it with `GQL.root_node_class = MyRootNode`.')
      end
    end

    class InvalidNodeClass < Error
      def initialize(node_class, super_class)
        super("#{node_class} must be a (subclass of) #{super_class}.")
      end
    end

    class UndefinedType < Error
      def initialize(name)
        types = GQL.field_types.keys.sort.map { |name| "`#{name}`" }
        types = types.size > 0 ? " Available types: #{types.to_sentence}." : ''

        super("The field type `#{name}` is undefined. Define it with `GQL.field_types[my_type] = MyFieldType`.#{types}")
      end
    end

    class UndefinedCall < Error
      def initialize(name, node_class)
        calls = node_class.call_classes.keys.sort.map { |name| "`#{name}`" }
        calls = calls.size > 0 ? " Available calls: #{calls.to_sentence}." : ''

        super("#{node_class} has no call named `#{name}`.#{calls}")
      end
    end

    class UndefinedField < Error
      def initialize(name, node_class)
        fields = node_class.field_classes.keys.sort.map { |name| "`#{name}`" }
        fields = fields.size > 0 ? " Available fields: #{fields.to_sentence}." : ''

        super("#{node_class} has no field named `#{name}`.#{fields}")
      end
    end

    class ParseError < Error
      def initialize(value, token)
        token = 'value' if token == 'error'

        super("Unexpected #{token}: `#{value}`.")
      end
    end
  end
end
