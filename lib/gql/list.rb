require 'active_support/core_ext/class/attribute'

module GQL
  class Connection < Node
    class_attribute :node_class, instance_accessor: false, instance_predicate: false

    class << self
      def build_class(node_class)
        node_class ||= self.node_class

        Class.new(self).tap do |connection_class|
          connection_class.array :edges, node_class: node_class do
            target
          end
        end
      end
    end
  end
end
