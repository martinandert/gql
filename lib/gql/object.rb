require 'active_support/core_ext/class/attribute'

module GQL
  class Object < Field
    class_attribute :object_class, instance_accessor: false, instance_predicate: false

    class << self
      def build_class(id, proc, options = {})
        object_class = options.delete(:class) || options.delete(:as)
        object_class = ::Hash.new(object_class) unless object_class.is_a?(::Hash)

        Class.new(self).tap do |klass|
          klass.id = id
          klass.proc = proc
          klass.object_class = object_class
        end
      end
    end

    def value
      field_class = Registry.fetch(self.class.object_class[target.class])

      field = field_class.new(ast_node, target, variables, context)
      field.value
    end
  end
end
