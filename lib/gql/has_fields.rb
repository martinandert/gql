require 'active_support/concern'
require 'active_support/core_ext/array/extract_options'
require 'active_support/core_ext/class/attribute'
require 'active_support/core_ext/string/inflections'

module GQL
  module HasFields
    extend ActiveSupport::Concern

    included do
      class_attribute :fields, :field_proc, instance_accessor: false, instance_predicate: false
      self.fields = {}
    end

    module ClassMethods
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
      rescue NoMethodError => exc
        raise Errors::NoMethodError.new(self, method, exc)
      end

      private
        def proc_for_field(id)
          instance_exec id, &(field_proc || GQL.default_field_proc)
        end

        def define_field_method(name, type)
          Node.define_singleton_method name do |*args, &block|
            options = args.extract_options!.merge(type: type)
            args = args.push(options)

            field(*args, &block)
          end
        end
    end

    private
      def value_of_fields(ast_fields)
        ast_fields.reduce({}) do |result, ast_field|
          key = ast_field.alias_id || ast_field.id

          result.merge key => value_of_field(ast_field)
        end
      end

      def value_of_field(ast_field)
        if ast_field.id == :node
          field = self.class.new(ast_field, target, variables, context)
          field.value
        else
          field_class = field_class_for_id(ast_field.id)
          next_target = target_for_field(target, field_class.proc)

          field = field_class.new(ast_field, next_target, variables, context)
          field.value
        end
      end

      def field_class_for_id(id)
        self.class.fields[id] or raise Errors::FieldNotFound.new(id, self.class)
      end

      def target_for_field(current_target, proc)
        method = ExecutionContext.new(current_target, context)
        method.execute proc
      end

      class ExecutionContext < Struct.new(:target, :context)
        def execute(method, args = [])
          instance_exec(*args, &method)
        end
      end
  end
end
