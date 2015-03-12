require 'active_support/core_ext/class/subclasses'

module GQL
  class Config
    def root_node_class
      @@root_node_class ||= nil
    end

    def root_node_class=(value)
      unless value.nil? || value <= Node
        raise Errors::InvalidNodeClass.new(value, Node)
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
      unless value.nil? || value <= Node
        raise Errors::InvalidNodeClass.new(value, Node)
      end

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
        return if Node.fields.has_key? :__type__

        type_field_class = Node.object :__type__, -> { field_class }, node_class: Schema::Field

        Node.descendants.each do |node_class|
          node_class.fields[:__type__] = type_field_class
        end
      end

      def switch_off_type_field
        return unless Node.fields.has_key? :__type__

        [Node, *Node.descendants].each do |node_class|
          node_class.remove_field :__type__
        end
      end

      def switch_on_execution_context
        Node.send :remove_const, :ExecutionContext if Node.const_defined?(:ExecutionContext)
        Node.const_set :ExecutionContext, Node::ExecutionContextDebug
      end

      def switch_off_execution_context
        Node.send :remove_const, :ExecutionContext if Node.const_defined?(:ExecutionContext)
        Node.const_set :ExecutionContext, Node::ExecutionContextNoDebug
      end

  end
end
