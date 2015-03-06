require 'active_support/core_ext/class/attribute'
require 'active_support/core_ext/string/inflections'
require 'active_support/core_ext/array/extract_options'

module GQL
  class Object < Field
    class_attribute :fields, :node_class, instance_writer: false, instance_predicate: false
    self.fields = {}

    class << self
      alias_method :original_build_class, :build_class

      def build_class(id, options = {})
        if id == :object
          node_class = options.delete(:node_class) || self.node_class

          Object.validate_is_subclass! node_class, 'node'

          Class.new(node_class).tap do |field_class|
            field_class.id = id.to_s
            field_class.target_method = options[:target_method]
          end
        else
          original_build_class id, options
        end
      end

      def field(id, *args)
        options = args.extract_options!
        options[:target_method] ||= args.shift || -> { target.public_send(id) }

        field_type = options.delete(:type)

        Field.validate_is_subclass! field_type, 'type'

        field_class = field_type.build_class(id, options)

        self.const_set "#{id.to_s.camelize}Field", field_class
        self.fields = fields.merge(id.to_sym => field_class)
      end

      def cursor(id_or_target_method)
        id = id_or_target_method.is_a?(Proc) ? nil : id_or_target_method
        target_method = id ? -> { target.public_send(id) } : id_or_target_method

        field :cursor, target_method, type: Simple
      end

      def respond_to?(method, *args)
        GQL.field_types.has_key?(method) || super
      end

      def method_missing(method, *args, &block)
        if field_type = GQL.field_types[method]
          options = args.extract_options!.merge(type: field_type)

          field(*args.push(options), &block)
        else
          super
        end
      rescue NoMethodError => exc
        raise Errors::UndefinedFieldType, method
      end
    end

    def value
      if ast_node.respond_to? :object
        object = self.class.new(ast_node.object, target, variables, context)
        object.value
      elsif ast_node.respond_to? :fields
        ast_node.fields.reduce({}) do |result, ast_field|
          key = ast_field.alias_id || ast_field.id

          result.merge key => value_of_field(ast_field)
        end
      else
        super
      end
    end

    private
      def value_of_field(ast_field)
        if ast_field.id == :node
          field = self.class.new(ast_field, target, variables, context)
          field.value
        else
          field_class = self.class.fields[ast_field.id]

          if field_class.nil?
            raise Errors::UndefinedField.new(ast_field.id, self.class)
          end

          method = Node::Method.new(target, context)
          target = method.execute(field_class.target_method)

          field = field_class.new(ast_field, target, variables, context)
          field.value
        end
      end
  end
end
