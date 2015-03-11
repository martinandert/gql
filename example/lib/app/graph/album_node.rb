module App
  module Graph
    class AlbumNode < ModelNode
      string      :title
      object      :band,        node_class: BandNode
      connection  :songs,       item_class: SongNode
      date        :released_on

      string    :band_name,   -> { target.band.name }
      number    :songs_count, -> { target.songs.count }
      duration  :duration,    -> { target.songs.pluck(:duration).reduce(0, &:+) }
    end
  end
end
