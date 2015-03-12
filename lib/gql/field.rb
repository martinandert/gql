require 'active_support/core_ext/class/attribute'

require 'gql/has_calls'
require 'gql/has_fields'

module GQL
  class Field
    class_attribute :id, :proc, instance_accessor: false, instance_predicate: false

    class << self
      def build_class(id, proc, options = {})
        Class.new(self).tap do |field_class|
          field_class.id = id.to_s
          field_class.proc = proc
        end
      end

      def validate_is_subclass!(subclass, name)
        if subclass.nil?
          raise Errors::FieldClassNotSet.new(self, name)
        end

        unless subclass <= self
          raise Errors::InvalidFieldClass.new(subclass, self)
        end
      end
    end

    include HasCalls
    include HasFields

    attr_reader :ast_node, :target, :variables, :context

    def initialize(ast_node, target, variables, context)
      @ast_node, @target = ast_node, target
      @variables, @context = variables, context
    end

    def value
      if ast_call = ast_node.call
        value_of_call ast_call
      elsif ast_fields = ast_node.fields
        value_of_fields ast_fields
      else
        scalar_value
      end
    end

    def scalar_value
      nil
    end
  end
end
