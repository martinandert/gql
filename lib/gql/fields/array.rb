require 'active_support/core_ext/class/attribute'

module GQL
  module Fields
    class Array < Field
      class_attribute :node_class, instance_accessor: false, instance_predicate: false

      class << self
        def build_class(name, method, options = {})
          node_class = options[:node_class] || self.node_class

          if node_class.nil?
            raise Errors::UndefinedNodeClass.new(self, 'node')
          end

          unless node_class <= GQL::Node
            raise Errors::InvalidNodeClass.new(node_class, GQL::Node)
          end

          Class.new(self).tap do |field_class|
            field_class.id = name.to_s
            field_class.method = method
            field_class.node_class = node_class
          end
        end
      end

      call size: Integer do
        target.size
      end

      def value
        target.map do |item|
          node = self.class.node_class.new(ast_node, item, variables, context)
          node.value
        end
      end

      def raw_value
        nil
      end
    end
  end
end
