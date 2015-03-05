require 'active_support/core_ext/class/attribute'

module GQL
  class Field < Node
    class Method
      attr_reader :target, :context

      def initialize(target, context)
        @target, @context = target, context
      end

      def execute(method)
        instance_exec(&method)
      end
    end

    class_attribute :id, :method, instance_accessor: false, instance_predicate: false

    class << self
      def build_class(id, method, options = {})
        Class.new(self).tap do |field_class|
          field_class.id = id.to_s
          field_class.method = method
        end
      end
    end

    def raw_value
      target
    end
  end
end
