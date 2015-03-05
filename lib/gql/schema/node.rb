module GQL
  module Schema
    class Node < GQL::Node
      string :type do
        target.name
      end

      connection :calls, :connection_class => Connection, :node_class => Call do
        target.calls.values
      end

      connection :fields, :connection_class => Connection, :node_class => Field do
        target.fields.values
      end
    end
  end
end
