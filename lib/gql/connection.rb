module GQL
  class Connection < Node
    field :edges

    def initialize(node_class, *args)
      super(*args)

      @node_class = node_class
    end

    alias :items :__target

    def edges_ast_node
      @edges_ast_node ||= @ast_node.fields.find { |f| f.name == :edges }
    end

    def edges
      raise Errors::InvalidNodeClass.new(@node_class, Node) unless @node_class < Node

      items.map do |item|
        node = @node_class.new(edges_ast_node, item, @variables, __context)
        node.__value
      end
    end

    EdgesField.class_eval do
      def __value
        if @ast_node.fields
          __target
        else
          nil
        end
      end
    end
  end
end
