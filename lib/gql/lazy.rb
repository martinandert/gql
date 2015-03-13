require 'active_support/core_ext/class/attribute'

module GQL
  class Lazy < Field
    class_attribute :owner, :type, :options, instance_accessor: false, instance_predicate: false

    class << self
      def build_class(id, proc, options)
        Class.new(self).tap do |field_class|
          field_class.owner = options.delete(:owner)
          field_class.type = options.delete(:type)
          field_class.id = id
          field_class.proc = proc
          field_class.options = options
        end
      end

      def resolve
        owner.remove_field id
        owner.add_field id, proc, options.merge(type: Registry.fetch(type))
      end
    end

    def value
      field_class = self.class.resolve

      field = field_class.new(ast_node, target, variables, context)
      field.value
    end
  end
end
