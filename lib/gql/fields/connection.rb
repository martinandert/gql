require 'active_support/core_ext/class/attribute'

module GQL
  module Fields
    class Connection < Field
      class_attribute :connection_class, instance_accessor: false, instance_predicate: false
      self.connection_class = GQL::Connection

      class << self
        def build_class(id, method, options = {})
          connection_class = options[:connection_class] || self.connection_class

          if connection_class.nil?
            raise Errors::UndefinedNodeClass.new(self, 'connection')
          end

          unless connection_class <= GQL::Connection
            raise Errors::InvalidNodeClass.new(connection_class, GQL::Connection)
          end

          Class.new(self).tap do |field_class|
            field_class.id = id.to_s
            field_class.method = method
            field_class.connection_class = connection_class.build_class(options[:node_class])
          end
        end
      end

      def value
        connection = self.class.connection_class.new(ast_node, target, variables, context)
        connection.value
      end
    end
  end
end
