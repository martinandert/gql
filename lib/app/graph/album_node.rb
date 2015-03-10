module App
  module Graph
    class AlbumNode < ModelNode
      string      :title
      object      :band,        node_class: BandNode
      connection  :songs,       item_class: SongNode
      date        :released_on
    end
  end
end
