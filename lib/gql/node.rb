require 'active_support/core_ext/class/attribute'
require 'active_support/core_ext/string/inflections'
require 'active_support/core_ext/array/extract_options'
require 'active_support/core_ext/object/try'

module GQL
  class Node
    class ExecutionContext
      attr_reader :target, :context

      def initialize(target, context)
        @target, @context = target, context
      end

      def execute(method, args = [])
        instance_exec(*args, &method)
      end
    end

    class_attribute :id, :proc, :calls, :call_proc, :fields, :field_proc, instance_accessor: false, instance_predicate: false

    self.calls = {}
    self.fields = {}

    class << self
      def build_class(id, proc, options = {})
        Class.new(self).tap do |field_class|
          field_class.id = id.to_s
          field_class.proc = proc
        end
      end

      def call(id, *args)
        options = args.extract_options!

        proc_or_class = args.shift || call_proc && instance_exec(id, &call_proc) || instance_exec(id, &GQL.default_call_proc)
        result_class = options[:returns] || proc_or_class.try(:result_class)

        if result_class.is_a? ::Array
          if result_class.size == 1
            result_class.unshift GQL.default_list_class
          end

          options = {
            list_class: result_class.first,
            item_class: result_class.last
          }

          result_class = Connection.build_class(:result, nil, options)
        elsif result_class
          Node.validate_is_subclass! result_class, 'result'
        end

        call_class =
          if proc_or_class.is_a? Proc
            Class.new(Call).tap do |klass|
              klass.class_eval do
                self.proc = proc_or_class

                def execute(*args)
                  instance_exec(*args, &self.class.proc)
                end
              end

            end
          else
            Class.new(proc_or_class)
          end

        call_class.id = id.to_s
        call_class.result_class = result_class

        self.const_set "#{id.to_s.camelize}Call", call_class
        self.calls = calls.merge(id.to_sym => call_class)
      end

      def field(id, *args)
        options = args.extract_options!
        type = options.delete(:type) || Node
        proc = args.shift || proc_for_field(id)

        Node.validate_is_subclass! type, 'type'

        type.build_class(id, proc, options).tap do |field_class|
          self.const_set "#{id.to_s.camelize}Field", field_class
          self.fields = fields.merge(id.to_sym => field_class)
        end
      end

      def cursor(id_or_proc)
        id = id_or_proc.is_a?(Proc) ? nil : id_or_proc
        proc = id ? -> { target.public_send(id) } : id_or_proc

        field :cursor, proc, type: Raw
      end

      def validate_is_subclass!(subclass, name)
        if subclass.nil?
          raise Errors::UndefinedNodeClass.new(self, name)
        end

        unless subclass <= self
          raise Errors::InvalidNodeClass.new(subclass, self)
        end
      end

      def respond_to?(method, *args)
        super || GQL.field_types.has_key?(method)
      end

      def method_missing(method, *args, &block)
        if type = GQL.field_types[method]
          define_field_method method, type
          send method, *args, &block
        else
          super
        end
      rescue NoMethodError
        raise Errors::UndefinedFieldType, method
      end

      private
        def proc_for_field(id)
          if field_proc
            instance_exec id, &field_proc
          else
            instance_exec id, &GQL.default_field_proc
          end
        end

        def define_field_method(name, type)
          Node.define_singleton_method name do |*margs, &mblock|
            options = margs.extract_options!.merge(type: type)
            margs = margs.push(options)

            field(*margs, &mblock)
          end
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

      call_class.execute(self.class, ast_call, target, variables, context)
    end

    def value_of_fields(ast_fields)
      ast_fields.reduce({}) do |result, ast_field|
        key = ast_field.alias_id || ast_field.id

        result.merge key => value_of_field(ast_field)
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

        method = ExecutionContext.new(target, context)
        target = method.execute(field_class.proc)

        field = field_class.new(ast_field, target, variables, context)
        field.value
      end
    end

    def raw_value
      nil
    end
  end
end
