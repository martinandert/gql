require 'active_support/core_ext/class/attribute'

module GQL
  class Call < Node
    class_attribute :result_class, :target_method, instance_writer: false, instance_predicate: false

    class << self
      alias_method :original_build_class, :build_class

      def build_class(id, options = {})
        result_class = options[:result_class] || self.result_class

        if result_class.is_a? ::Array
          if result_class.size == 1
            result_class.unshift GQL.default_list_class || Connection
          end

          connection_options = {
            list_class: result_class.first,
            item_class: result_class.last
          }

          result_class = Connection.build_class(:result, connection_options)
        elsif result_class
          Field.validate_is_subclass! result_class, 'result'
        end

        options[:result_class] = result_class

        original_build_class id, options
      end
    end

    attr_reader :caller_class

    def initialize(caller_class, *args)
      @caller_class = caller_class
      super(*args)
    end

    def value
      args = substitute_variables(ast_node.arguments)

      method = Node::Method.new(target, context)
      target = method.execute(target_method, args)

      result = (result_class || caller_class).new(ast_node, target, variables, context)
      result.value
    end

    private
      def substitute_variables(args)
        args.map { |arg| arg.is_a?(::Symbol) ? variables[arg] : arg }
      end
  end
end
