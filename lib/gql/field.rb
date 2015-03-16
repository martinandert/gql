require 'active_support/core_ext/class/attribute'

require 'gql/mixins/common'
require 'gql/mixins/has_calls'
require 'gql/mixins/has_fields'

module GQL
  class Field
    ExecutionContext = Struct.new(:target, :context, :field_class)

    class_attribute :id, :proc, instance_accessor: false, instance_predicate: false

    class << self
      def build_class(id, proc, options = {})
        Class.new(self).tap do |field_class|
          field_class.id = id.to_s
          field_class.proc = proc
        end
      end

      def execute(parent, ast_node, target, variables, context)
        args    = [target, context, GQL.debug ? parent : nil]
        target  = ExecutionContext.new(*args).instance_exec(&proc)
        field   = new(ast_node, target, variables, context)

        field.value
      end
    end

    extend Mixins::Common
    include Mixins::HasCalls
    include Mixins::HasFields

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
