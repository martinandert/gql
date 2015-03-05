require 'active_support/core_ext/class/attribute'

module GQL
  class Object < Field
    class_attribute :node_class, instance_accessor: false, instance_predicate: false

    class << self
      def build_class(id, method, options = {})
        node_class = options[:node_class] || self.node_class

        if node_class.nil?
          raise Errors::UndefinedNodeClass.new(self, 'node')
        end

        unless node_class <= Node
          raise Errors::InvalidNodeClass.new(node_class, Node)
        end

        Class.new(self).tap do |field_class|
          field_class.id = id.to_s
          field_class.method = method
          field_class.node_class = node_class
        end
      end
    end

    def value
      node = self.class.node_class.new(ast_node, target, variables, context)
      node.value
    end
  end
end
