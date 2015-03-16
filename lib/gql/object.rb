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
            -> target { object_class[target.class] }
          when ::Class, ::String
            -> _ { object_class }
          when ::Proc
            object_class
          else
            nil # raise error?
          end
        end
    end

    def value
      field_class = Registry.fetch(object_proc_result)

      field = field_class.new(ast_node, target, variables, context)
      field.value
    end

    private
      def object_proc_result
        proc = self.class.object_proc

        if proc.arity == 1
          proc.call target
        else
          proc.call target, context
        end
      end
  end
end
