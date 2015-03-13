module App
  module Graph
    class SongField < ModelField
      string      :title
      object      :album,   class: AlbumField
      object      :band,    class: BandField
      connection  :writers, item_class: PersonField
      number      :track_number
      duration    :duration
      string      :note

      string  :album_title,  -> { target.album.name }
      string  :band_name,   -> { target.band.name }
    end
  end
end
