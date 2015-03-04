require 'active_support/core_ext/class/attribute'

module GQL
  class Connection < Node
    class_attribute :node_class, instance_accessor: false, instance_predicate: false

    class << self
      def build_class(node_class)
        node_class ||= self.node_class

        raise Errors::UndefinedNodeClass.new(self, 'node') if node_class.nil?
        raise Errors::InvalidNodeClass.new(node_class, GQL::Node) unless node_class <= GQL::Node

        Class.new(self).tap do |connection_class|
          connection_class.node_class = node_class
        end
      end
    end

    def value_of_field(ast_field)
      if ast_field.name == :edges
        target.map do |item|
          node = self.class.node_class.new(ast_field, item, variables, context)
          node.value
        end
      else
        super
      end
    end
  end
end
