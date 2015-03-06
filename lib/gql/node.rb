require 'active_support/core_ext/class/attribute'
require 'active_support/core_ext/string/inflections'
require 'active_support/core_ext/array/extract_options'

module GQL
  class Node
    class_attribute :calls, :fields, instance_accessor: false, instance_predicate: false

    self.calls = {}
    self.fields = {}

    class << self
      def call(id, result_class = nil, body = nil)
        if body.nil? && result_class.is_a?(Proc)
          body = result_class
          result_class = nil
        end

        body ||= lambda { |*args| target.public_send(id, *args) }

        call_class = Call.build_class(id, result_class, body)

        self.const_set "#{id.to_s.camelize}Call", call_class
        self.calls = calls.merge(id.to_sym => call_class)
      end

      def field(*ids, &block)
        options = ids.extract_options!

        ids.each do |id|
          method = block || lambda { target.public_send(id) }
          field_type = options.delete(:type) || Field

          validate_is_subclass_of! field_type, Field, 'type'

          field_class = field_type.build_class(id, method, options)

          self.const_set "#{id.to_s.camelize}Field", field_class
          self.fields = fields.merge(id.to_sym => field_class)
        end
      end

      def cursor(id = nil, &block)
        body = id ? -> { target.public_send(id) } : block
        field :cursor, { type: Simple }, &body
      end

      def validate_is_subclass_of!(left, right, name)
        if left.nil?
          raise Errors::UndefinedNodeClass.new(self, name)
        end

        unless left <= right
          raise Errors::InvalidNodeClass.new(left, right)
        end
      end

      def method_missing(method, *ids, &block)
        if field_type = GQL.field_types[method]
          options = ids.extract_options!

          field(*ids, options.merge(type: field_type), &block)
        else
          super
        end
      rescue NoMethodError => exc
        raise Errors::UndefinedFieldType, method
      end
    end

    attr_reader :ast_node, :target, :variables, :context

    def initialize(ast_node, target, variables, context)
      @ast_node, @target = ast_node, target
      @variables, @context = variables, context
    end

    def value
      if ast_call = ast_node.call
        value_of_call ast_call
      elsif ast_fields = ast_node.fields
        value_of_fields ast_fields
      else
        raw_value
      end
    end

    def value_of_call(ast_call)
      call_class = self.class.calls[ast_call.id]

      if call_class.nil?
        raise Errors::UndefinedCall.new(ast_call.id, self.class)
      end

      call = call_class.new(self, ast_call, target, variables, context)
      call.execute
    end

    def value_of_fields(ast_fields)
      ast_fields.reduce({}) do |memo, ast_field|
        key = ast_field.alias_id || ast_field.id

        memo.merge key => value_of_field(ast_field)
      end
    end

    def value_of_field(ast_field)
      case ast_field.id
      when :node
        field = self.class.new(ast_field, target, variables, context)
        field.value
      else
        field_class = self.class.fields[ast_field.id]

        if field_class.nil?
          raise Errors::UndefinedField.new(ast_field.id, self.class)
        end

        method = Field::Method.new(target, context)
        target = method.execute(field_class.method)

        field = field_class.new(ast_field, target, variables, context)
        field.value
      end
    end

    def raw_value
      nil
    end
  end
end
