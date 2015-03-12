require 'active_support/core_ext/array/conversions'
require 'active_support/core_ext/string/inflections'

module GQL
  class Error < StandardError
    attr_reader :code, :handle

    def initialize(msg, code = 100, handle = nil)
      @code, @handle = code, handle
      super(msg)
    end

    def as_json
      result = {
        error: {
          code: code,
          type: self.class.name.split('::').last.underscore
        }
      }

      result[:error][:handle] = handle.to_s if handle
      result[:error][:message] = message if ENV['DEBUG']

      result
    end
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

        super(msg, 111, id)
      end
    end

    class FieldNotFound < NotFoundError
      def initialize(id, node_class)
        msg = construct_message(node_class, id, 'field', :fields)

        super(msg, 112, id)
      end
    end

    class VariableNotFound < NotFoundError
      def initialize(id)
        msg = "The variable named `<#{id}>' has no value."

        super(msg, 113, id)
      end
    end

    class InvalidNodeClass < Error
      def initialize(node_class, super_class)
        msg = "#{node_class} must be a (subclass of) #{super_class}."

        super(msg, 121)
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
        msg << GQL.field_types.keys.sort.map { |key| "`#{key}'" }.to_sentence

        super(msg, 122)
      end
    end

    class RootClassNotSet < Error
      def initialize
        msg =  "GQL root node class is not set. "
        msg << "Set it with `GQL.root_node_class = MyRootNode'."

        super(msg, 123)
      end
    end

    class ScanError < Error
      def initialize(msg)
        super(msg, 131)
      end
    end

    class SyntaxError < Error
      def initialize(lineno, value, token)
        token = 'character' if token == 'error' || token == %Q{"#{value}"}
        msg = "Unexpected #{token}: `#{value}' (line #{lineno})."

        super(msg, 132, value)
      end
    end

    class UndefinedNodeClass < Error
      def initialize(node_class, name)
        msg =  "#{node_class} must have a #{name} class set. "
        msg << "Set it with `self.#{name}_class = My#{name.camelize}Class'."

        super(msg, 124)
      end
    end
  end
end
