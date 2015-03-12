require 'active_support/core_ext/class/subclasses'

module GQL
  class Config
    def root_field_class
      @@root_field_class ||= nil
    end

    def root_field_class=(value)
      unless value.nil? || value <= Field
        raise Errors::InvalidFieldClass.new(value, Field)
      end

      @@root_field_class = value
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

    def default_list_field_class
      @@default_list_field_class ||= Field
    end

    def default_list_field_class=(value)
      unless value.nil? || value <= Field
        raise Errors::InvalidFieldClass.new(value, Field)
      end

      @@default_list_field_class = value
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

      return if value == @@debug

      value ? switch_debug_on : switch_debug_off

      @@debug = value
    end

    private
      def switch_debug_on
        switch_on_type_field
        switch_on_execution_context
      end

      def switch_debug_off
        switch_off_type_field
        switch_off_execution_context
      end

      def switch_on_type_field
        return if Field.has_field? :__type__

        type_field_class = Field.object :__type__, -> { field_class }, field_class: Schema::Field

        Field.descendants.each do |field_class|
          field_class.fields[:__type__] = type_field_class
        end
      end

      def switch_off_type_field
        return unless Field.has_field? :__type__

        [Field, *Field.descendants].each do |field_class|
          field_class.remove_field :__type__
        end
      end

      def switch_on_execution_context
        Field.send :remove_const, :ExecutionContext if Field.const_defined?(:ExecutionContext)
        Field.const_set :ExecutionContext, Field::ExecutionContextDebug
      end

      def switch_off_execution_context
        Field.send :remove_const, :ExecutionContext if Field.const_defined?(:ExecutionContext)
        Field.const_set :ExecutionContext, Field::ExecutionContextNoDebug
      end

  end
end
