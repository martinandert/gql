require 'active_support/core_ext/class/attribute'

module GQL
  class Array < Field
    class_attribute :item_class, instance_writer: false, instance_predicate: false

    class << self
      alias_method :original_build_class, :build_class

      def build_class(id, options = {})
        options[:item_class] ||= self.item_class

        Field.validate_is_subclass! options[:item_class], 'item'

        original_build_class id, options
      end
    end

    call :size, Number, -> { target.size }

    def value
      target.map do |item|
        node = item_class.new(ast_node, item, variables, context)
        node.value
      end
    end
  end
end
