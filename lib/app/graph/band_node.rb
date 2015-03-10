module App
  module Graph
    class BandNode < ModelNode
      connection :members,  item_class: PersonNode
      connection :albums,   item_class: AlbumNode
      connection :songs,    item_class: SongNode
    end
  end
end
