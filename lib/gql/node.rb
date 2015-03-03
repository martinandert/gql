require 'active_support/core_ext/class/attribute'
require 'active_support/core_ext/string/inflections'

module GQL
  class Node
    class_attribute :call_classes
    self.call_classes = {}

    class_attribute :field_classes
    self.field_classes = {}

    class << self
      def cursor(method_name)
        define_method :cursor do
          __target.send(method_name).to_s
        end
      end

      def call(name, options = {}, &block)
        result_class = options[:returns]
        function = block || lambda { |*args| target.public_send(name, *args) }

        if result_class.is_a? Array
          result_class.unshift Connection if result_class.size == 1
          result_class.unshift Fields::Connection if result_class.size == 2

          field_class, connection_class, node_class = result_class

          raise Errors::InvalidNodeClass.new(field_class, Fields::Connection) unless field_class <= Fields::Connection

          result_class = Class.new(field_class)
          result_class.const_set :NODE_CLASS, node_class
          result_class.const_set :CONNECTION_CLASS, connection_class
        else
          raise Errors::InvalidNodeClass.new(result_class, Node) unless result_class.nil? || result_class < Node
        end

        call_class = Class.new(Call)
        call_class.const_set :Function, function
        call_class.const_set :Result, result_class

        self.const_set "#{name.to_s.camelize}Call", call_class
        self.call_classes = call_classes.merge(name => call_class)
      end

      def fields(&block)
        instance_eval &block
      end

      def field(*names, base_class: nil, node_class: nil, connection_class: nil)
        classes = names.reduce({}) do |result, name|
          base_class ||= Field

          raise Errors::InvalidNodeClass.new(base_class, Field) unless base_class <= Field

          field_class = Class.new(base_class)

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

    attr_reader :__target, :__context

    def initialize(ast_node, target, variables, context)
      @ast_node, @__target = ast_node, target
      @variables, @__context = variables, context
    end

    def __value
      if ast_call = @ast_node.call
        call_class = self.class.call_classes[ast_call.name]

        raise Errors::UndefinedCall.new(ast_call.name, self.class.superclass) if call_class.nil?

        call = call_class.new(self, ast_call, __target, @variables, __context)
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

              raise Errors::UndefinedField.new(ast_field.name, self.class) if field_class.nil?
              raise Errors::InvalidNodeClass.new(field_class.superclass, Field) unless field_class <= Field

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
