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
      rescue NoMethodError
        raise Errors::UndefinedFieldType, method
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
  end
end
