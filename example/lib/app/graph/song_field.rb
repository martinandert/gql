module App
  module Graph
    class SongField < ModelField
      string      :title
      object      :album,   object_class: AlbumField
      object      :band,    object_class: BandField
      connection  :writers, item_class: PersonField
      number      :track_number
      duration    :duration
      string      :note

      string  :album_title,  -> { target.album.name }
      string  :band_name,   -> { target.band.name }
    end
  end
end
