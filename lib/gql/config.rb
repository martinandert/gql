module GQL
  class Config
    def root_node_class
      @@root_node_class ||= nil
    end

    def root_node_class=(value)
      unless value.nil? || value <= Node
        raise Errors::InvalidNodeClass.new(value, Node)
      end

      if ENV['DEBUG']
        value.call :_schema, Schema::Node, -> { context[:_schema_root] }
      end

      @@root_node_class = value
    end

    def field_types
      @@field_types ||= {}
    end

    def field_types=(value)
      @@field_types = value
    end
  end
end
