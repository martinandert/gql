module App
  module Graph
    class SongNode < ModelNode
      string      :title
      object      :album,   node_class: AlbumNode
      object      :band,    node_class: BandNode
      connection  :writers, item_class: PersonNode
      number      :track_number
      duration    :duration
      string      :note

      string  :album_title,  -> { target.album.name }
      string  :band_name,   -> { target.band.name }
    end
  end
end
