require 'active_support/core_ext/class/attribute'

module GQL
  class Object < Field
    class_attribute :field_class, instance_accessor: false, instance_predicate: false

    class << self
      def build_class(id, proc, options = {})
        field_class = options.delete(:field_class)
        field_class = ::Hash.new(field_class) unless field_class.is_a?(::Hash)

        Class.new(self).tap do |klass|
          klass.id = id.to_s
          klass.proc = proc
          klass.field_class = field_class
        end
      end
    end

    def value
      field_class = Registry.fetch(self.class.field_class[target.class])

      field = field_class.new(ast_node, target, variables, context)
      field.value
    end
  end
end
