require 'active_support/core_ext/array/conversions'
require 'active_support/core_ext/string/inflections'

module GQL
  class Error < StandardError
  end

  module Errors
    class UndefinedRoot < Error
      def initialize
        super('Root node class is undefined. Define it with `GQL.root_node_class = MyRootNode`.')
      end
    end

    class UndefinedNodeClass < Error
      def initialize(node_class, name)
        super("#{node_class} must define a #{name} class. Set it with `self.#{name}_class = My#{name.camelize}Class`.")
      end
    end

    class InvalidNodeClass < Error
      def initialize(node_class, super_class)
        super("#{node_class} must be a (subclass of) #{super_class}.")
      end
    end

    class UndefinedFieldType < Error
      def initialize(id)
        types = GQL.field_types.keys.sort.map { |id| "`#{id}`" }
        types = types.size > 0 ? " Available types: #{types.to_sentence}." : ''

        super("The field type `#{id}` is undefined. Define it with `GQL.field_types[:#{id}] = My#{id.to_s.camelize}`.#{types}")
      end
    end

    class UndefinedCall < Error
      def initialize(id, node_class)
        calls = node_class.calls.keys.sort.map { |id| "`#{id}`" }
        calls = calls.size > 0 ? " Available calls: #{calls.to_sentence}." : ''

        super("#{node_class} has no call named `#{id}`.#{calls}")
      end
    end

    class UndefinedField < Error
      def initialize(id, node_class)
        fields = node_class.fields.keys.sort.map { |id| "`#{id}`" }
        fields = fields.size > 0 ? " Available fields: #{fields.to_sentence}." : ''

        super("#{node_class} has no field named `#{id}`.#{fields}")
      end
    end

    class SyntaxError < Error
      def initialize(value, token)
        token = 'character' if token == 'error' || token == %Q{"#{value}"}

        super("Unexpected #{token}: `#{value}`.")
      end
    end
  end
end
