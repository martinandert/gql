require 'active_support/core_ext/class/attribute'

module GQL
  class Object < Node
    class << self
      def build_class(id, proc, options = {})
        node_class = options.delete(:node_class)

        Node.validate_is_subclass! node_class, 'node'

        node_class.build_class id, proc, options
      end
    end
  end
end
