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
        value.call :_schema, -> { context[:_schema_root] }, returns: Schema::Root
      end

      @@root_node_class = value
    end

    def field_types
      @@field_types ||= {}
    end

    def field_types=(value)
      @@field_types = value
    end

    def default_list_class
      @@default_list_class ||= Node
    end

    def default_list_class=(value)
      @@default_list_class = value
    end
  end
end
