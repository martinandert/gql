module App
  module Graph
    class SongNode < ModelNode
      string      :title
      object      :album, node_class: AlbumNode
      connection  :writers, item_class: PersonNode
      number      :track_number
      duration    :duration
      string      :note
    end
  end
end
