require 'active_support/core_ext/module/attribute_accessors'

module GQL
  class Node
    class Method
      attr_reader :target, :context

      def initialize(target, context)
        @target, @context = target, context
      end

      def execute(method, args = [])
        instance_exec(*args, &method)
      end
    end

    mattr_accessor :id, :target_method, instance_reader: false

    class << self
      def build_class(id, options = {})
        Class.new(self).tap do |node_class|
          node_class.id = id.to_s

          options.each do |key, value|
            node_class.send :"#{key}=", value
          end
        end
      end

      def validate_is_subclass!(klass, name)
        if klass.nil?
          raise Errors::UndefinedNodeClass.new(self, name)
        end

        unless klass <= self
          raise Errors::InvalidNodeClass.new(klass, self)
        end
      end
    end

    attr_reader :ast_node, :target, :variables, :context

    def initialize(ast_node, target, variables, context)
      @ast_node, @target = ast_node, target
      @variables, @context = variables, context
    end

    def value
      raw_value
    end

    def raw_value
      nil
    end
  end
end
