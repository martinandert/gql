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

    def root_target_proc
      @@root_target_proc ||= -> context { nil }
    end

    def root_target_proc=(value)
      @@root_target_proc = value
    end

    def field_types
      @@field_types ||= {
        array:      Array,
        boolean:    Boolean,
        connection: Connection,
        number:     Number,
        object:     Object,
        string:     String
      }
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

    def default_field_proc
      @@default_field_proc ||= -> id { -> { target.public_send(id) } }
    end

    def default_field_proc=(value)
      @@default_field_proc = value
    end

    def default_call_proc
      @@default_call_proc ||= -> id { -> (*args) { target.public_send(id, *args) } }
    end

    def default_call_proc=(value)
      @@default_call_proc = value
    end
  end
end
