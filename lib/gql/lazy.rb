require 'active_support/core_ext/class/attribute'

module GQL
  class Lazy < Field
    class_attribute :owner, :type, :options, instance_accessor: false, instance_predicate: false

    class << self
      def build_class(id, proc, options)
        Class.new(self).tap do |field_class|
          field_class.owner   = options.delete(:owner)
          field_class.type    = options.delete(:type)
          field_class.id      = id
          field_class.proc    = proc
          field_class.options = options
        end
      end

      def spur
        if type.is_a? ::Symbol
          field_type = GQL.field_types[type]
          raise Errors::UnknownFieldType.new(type, owner) unless field_type
          owner.send type, id, proc, options
        else
          owner.add_field id, proc, options.merge(type: Registry.fetch(type))
        end
      end
    end

    def value
      field_class = self.class.spur

      field = field_class.new(ast_node, target, variables, context)
      field.value
    end
  end
end
