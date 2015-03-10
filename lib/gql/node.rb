require 'active_support/core_ext/class/attribute'

require 'gql/has_calls'
require 'gql/has_fields'

module GQL
  class Node
    include HasCalls
    include HasFields

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
          raise Errors::UndefinedNodeClass.new(self, name)
        end

        unless subclass <= self
          raise Errors::InvalidNodeClass.new(subclass, self)
        end
      end
    end

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
        raw_value
      end
    end

    def raw_value
      nil
    end

    private
      def value_of_call(ast_call)
        call_class = self.class.calls[ast_call.id]

        if call_class.nil?
          raise Errors::UndefinedCall.new(ast_call.id, self.class)
        end

        call_class.execute(self.class, ast_call, target, variables, context)
      end

      def value_of_fields(ast_fields)
        ast_fields.reduce({}) do |result, ast_field|
          key = ast_field.alias_id || ast_field.id

          result.merge key => value_of_field(ast_field)
        end
      end

      def value_of_field(ast_field)
        if ast_field.id == :node
          field = self.class.new(ast_field, target, variables, context)
          field.value
        else
          field_class = field_class_for_id(ast_field.id)
          next_target = target_for_field(target, field_class.proc)

          field = field_class.new(ast_field, next_target, variables, context)
          field.value
        end
      end

      def field_class_for_id(id)
        self.class.fields[id] or raise Errors::UndefinedField.new(id, self.class)
      end

      def target_for_field(current_target, proc)
        method = ExecutionContext.new(current_target, context)
        method.execute proc
      end

      class ExecutionContext < Struct.new(:target, :context)
        def execute(method, args = [])
          instance_exec(*args, &method)
        end
      end
  end
end
