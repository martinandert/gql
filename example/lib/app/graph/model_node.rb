module App
  module Graph
    class ModelNode < GQL::Node
      cursor :slug

      number :id
      string :slug
      string :name

      string :type, -> { target.class.name.split('::').last.downcase }
    end
  end
end
