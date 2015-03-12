module App
  module Graph
    class SongField < ModelField
      string      :title
      object      :album,   field_class: AlbumField
      object      :band,    field_class: BandField
      connection  :writers, item_field_class: PersonField
      number      :track_number
      duration    :duration
      string      :note

      string  :album_title,  -> { target.album.name }
      string  :band_name,   -> { target.band.name }
    end
  end
end
