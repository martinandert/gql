require 'active_support/core_ext/class/attribute'
require 'active_support/core_ext/string/inflections'

module GQL
  class Node
    class_attribute :call_classes, :field_classes, instance_accessor: false, instance_predicate: false

    self.call_classes = {}
    self.field_classes = {}

    class << self
      def call(*names, &block)
        names_with_result_class = names.extract_options!

        names.each do |name|
          names_with_result_class[name] = nil
        end

        names_with_result_class.each do |name, result_class|
          method = block || lambda { |*args| target.public_send(name, *args) }
          call_class = Call.build_class(result_class, method)

          self.const_set "#{name.to_s.camelize}Call", call_class
          self.call_classes = call_classes.merge(name => call_class)
        end
      end

      def field(*names, field_type_class: nil, connection_class: nil, node_class: nil, &block)
        names.each do |name|
          method = block || lambda { target.public_send(name) }
          field_type_class ||= Field

          unless field_type_class <= Field
            raise Errors::InvalidNodeClass.new(field_type_class, Field)
          end

          field_class = field_type_class.build_class(method, connection_class, node_class)

          self.const_set "#{name.to_s.camelize}Field", field_class
          self.field_classes = field_classes.merge(name => field_class)
        end
      end

      def cursor(name = nil, &block)
        if name
          field :cursor, &-> { target.public_send(name) }
        elsif block_given?
          field :cursor, &block
        end
      end

      def method_missing(method, *names, &block)
        if field_type_class = GQL.field_types[method]
          options = names.extract_options!

          field(*names, options.merge(field_type_class: field_type_class), &block)
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
      call_class = self.class.call_classes[ast_call.name]

      if call_class.nil?
        raise Errors::UndefinedCall.new(ast_call.name, self.class.superclass)
      end

      call = call_class.new(self, ast_call, target, variables, context)
      call.execute
    end

    def value_of_fields(ast_fields)
      ast_fields.reduce({}) do |memo, ast_field|
        key = ast_field.alias_name || ast_field.name

        memo.merge key => value_of_field(ast_field)
      end
    end

    def value_of_field(ast_field)
      case ast_field.name
      when :node
        field = self.class.new(ast_field, target, variables, context)
        field.value
      else
        method = Field::Method.new(target, context)
        field_class = self.class.field_classes[ast_field.name]

        if field_class.nil?
          raise Errors::UndefinedField.new(ast_field.name, self.class)
        end

        next_target = method.execute(field_class.method)

        field = field_class.new(ast_field, next_target, variables, context)
        field.value
      end
    end

    def raw_value
      nil
    end
  end
end
