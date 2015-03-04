require 'active_support/core_ext/class/attribute'

module GQL
  module Fields
    class Object < Field
      class_attribute :node_class, instance_accessor: false, instance_predicate: false

      class << self
        def build_class(method, connection_class, node_class)
          node_class ||= self.node_class

          raise Errors::UndefinedNodeClass.new(self, 'node') if node_class.nil?
          raise Errors::InvalidNodeClass.new(node_class, GQL::Node) unless node_class <= GQL::Node

          Class.new(self).tap do |field_class|
            field_class.method = method
            field_class.node_class = node_class
          end
        end
      end

      def value_of_fields(*)
        node = self.class.node_class.new(ast_node, target, variables, context)
        node.value
      end

      def raw_value
        nil
      end
    end
  end
end
