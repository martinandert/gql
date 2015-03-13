module GQL
  class Config
    def root_class
      @@root_class ||= nil
    end

    def root_class=(value)
      @@root_class = value
    end

    def root_target_proc
      @@root_target_proc ||= -> context { nil }
    end

    def root_target_proc=(value)
      @@root_target_proc = value
    end

    def field_types
      @@field_types ||= {
        array:      'GQL::Array',
        boolean:    'GQL::Boolean',
        connection: 'GQL::Connection',
        number:     'GQL::Number',
        object:     'GQL::Object',
        string:     'GQL::String'
      }
    end

    def field_types=(value)
      @@field_types = value
    end

    def default_list_class
      @@default_list_class ||= 'GQL::Field'
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

    def debug
      if defined? @@debug
        @@debug
      else
        @@debug = nil
        self.debug = ENV.has_key?('DEBUG')
      end
    end

    def debug=(value)
      value = !!value

      @@debug = nil unless defined?(@@debug)

      return if value == @@debug

      value ? switch_debug_on : switch_debug_off

      @@debug = value
    end

    private
      def switch_debug_on
        Field.object :__type__, -> { field_class }, class: Schema::Field
        Field.send :remove_const, :ExecutionContext if Field.const_defined?(:ExecutionContext)
        Field.const_set :ExecutionContext, Field::ExecutionContextDebug
      end

      def switch_debug_off
        Field.remove_field :__type__
        Field.send :remove_const, :ExecutionContext if Field.const_defined?(:ExecutionContext)
        Field.const_set :ExecutionContext, Field::ExecutionContextNoDebug
      end

  end
end
