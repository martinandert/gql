module App
  module Graph
    class AlbumField < ModelField
      string      :title
      object      :band,        field_class: BandField
      connection  :songs,       item_field_class: SongField
      date        :released_on

      string    :band_name,   -> { target.band.name }
      number    :songs_count, -> { target.songs.count }
      duration  :duration,    -> { target.songs.pluck(:duration).reduce(0, &:+) }
    end
  end
end
