require 'active_support/core_ext/array/conversions'
require 'active_support/core_ext/string/inflections'

module GQL
  class Error < StandardError
  end

  module Errors
    class NotFoundError < Error
      private
        def construct_message(node_class, id, name, method)
          items = node_class.send(method).keys.sort.map { |key| "`#{key}'" }

          msg =  "#{node_class} has no #{name} named `#{id}'."
          msg << " Available #{name.pluralize}: #{items.to_sentence}." if items.any?
          msg
        end
    end

    class CallNotFound < NotFoundError
      def initialize(id, node_class)
        msg = construct_message(node_class, id, 'call', :calls)

        super(msg)
      end
    end

    class FieldNotFound < NotFoundError
      def initialize(id, node_class)
        msg = construct_message(node_class, id, 'field', :fields)

        super(msg)
      end
    end

    class InvalidNodeClass < Error
      def initialize(node_class, super_class)
        msg = "#{node_class} must be a (subclass of) #{super_class}."

        super(msg)
      end
    end

    class NoMethodError < Error
      attr_reader :cause

      def initialize(node_class, id, cause)
        @cause = cause

        msg =  "Undefined method `#{id}' for #{node_class}. "
        msg << "Did you try to add a field of type `#{id}'? "
        msg << "If so, you have to register your field type first "
        msg << "like this: `GQL.field_types[:#{id}] = My#{id.to_s.camelize}'. "
        msg << "The following field types are currently registered: "
        msg << GQL.field_types.keys.sort.map { |id| "`#{id}'" }.to_sentence

        super(msg)
      end
    end

    class RootClassNotSet < Error
      def initialize
        msg =  "GQL root node class is not set. "
        msg << "Set it with `GQL.root_node_class = MyRootNode'."

        super(msg)
      end
    end

    class ScanError < Error
    end

    class SyntaxError < Error
      def initialize(lineno, value, token)
        token = 'character' if token == 'error' || token == %Q{"#{value}"}
        msg = "Unexpected #{token}: `#{value}' (line #{lineno})."

        super(msg)
      end
    end

    class UndefinedNodeClass < Error
      def initialize(node_class, name)
        msg =  "#{node_class} must have a #{name} class set. "
        msg << "Set it with `self.#{name}_class = My#{name.camelize}Class'."

        super(msg)
      end
    end
  end
end
