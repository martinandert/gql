require 'active_support/core_ext/class/attribute'

module GQL
  class Object < Field
    class_attribute :object_proc, instance_accessor: false, instance_predicate: false

    class << self
      def build_class(id, proc, options = {})
        object_class = options.delete(:object_class) || options.delete(:as)
        object_proc  = object_proc_for_class(object_class)

        Class.new(self).tap do |klass|
          klass.id = id
          klass.proc = proc
          klass.object_proc = object_proc
        end
      end

      private
        def object_proc_for_class(object_class)
          case object_class
          when ::Hash
            -> target, _ { object_class[target.class] }
          when ::Class, ::String
            -> _, __ { object_class }
          when ::Proc
            object_class
          else
            nil # raise error?
          end
        end
    end

    def value
      field_class = Registry.fetch(self.class.object_proc.call(target, context))

      field = field_class.new(ast_node, target, variables, context)
      field.value
    end
  end
end
