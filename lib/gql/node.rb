require 'active_support/core_ext/class/attribute'
require 'active_support/core_ext/string/inflections'

module GQL
  class Node
    class_attribute :call_definitions
    self.call_definitions = {}

    class_attribute :field_classes
    self.field_classes = {}

    class << self
      def cursor(method_name)
        define_method :cursor do
          __target.send(method_name).to_s
        end
      end

      def call(name, options = {}, &block)
        definition = {
          returns: options[:returns],
          body: block || lambda { |*args| __target.public_send(name, *args) }
        }

        self.call_definitions = call_definitions.merge(name => definition)
      end

      def fields(&block)
        instance_eval &block
      end

      def field(*names, base_class: nil, node_class: nil, connection_class: nil)
        classes = names.reduce({}) do |result, name|
          field_class = Class.new(base_class || Field)
          field_class.const_set :NAME, name
          field_class.const_set :NODE_CLASS, node_class
          field_class.const_set :CONNECTION_CLASS, connection_class

          self.const_set "#{name.to_s.camelize}Field", field_class

          result.merge name => field_class
        end

        self.field_classes = field_classes.merge(classes)
      end

      def method_missing(method, *args, &block)
        if base_class = Schema.fields[method]
          options = args.extract_options!

          field(*args, options.merge(base_class: base_class))
        else
          super
        end
      rescue NoMethodError => exc
        raise Errors::UndefinedType, method
      end
    end

    call :_identity do
      target
    end

    attr_reader :__target, :__context

    def initialize(ast_node, target, variables, context)
      @ast_node, @__target = ast_node, target
      @variables, @__context = variables, context
    end

    def __value
      if ast_call = @ast_node.call
        definition = self.class.call_definitions[ast_call.name]

        raise Errors::UndefinedCall.new(ast_call.name, self.class) if definition.nil?

        call = Call.new(self, ast_call, __target, definition, @variables, __context)
        call.execute
      elsif ast_fields = @ast_node.fields
        ast_fields.reduce({}) do |memo, ast_field|
          key = ast_field.alias_name || ast_field.name

          val =
            case key
            when :node
              field = self.class.new(ast_field, __target, @variables, __context)
              field.__value
            when :cursor
              cursor
            else
              target = public_send(ast_field.name)
              field_class = self.class.field_classes[ast_field.name]

              raise Errors::InvalidNodeClass.new(field_class.superclass, Field) unless field_class < Field

              field = field_class.new(ast_field, target, @variables, __context)
              field.__value
            end

          memo.merge key => val
        end
      else
        __raw_value
      end
    end

    def __raw_value
      nil
    end

    def method_missing(method, *args, &block)
      if __target.respond_to? method
        __target.public_send method, *args, &block
      else
        super
      end
    rescue NoMethodError => exc
      raise Errors::UndefinedField.new(method, self.class)
    end
  end
end
