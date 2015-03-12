module App
  module Graph
    class RootField < GQL::Field
      connection :people, -> { Models::Person.all }, item_field_class: PersonField
      connection :bands,  -> { Models::Band.all   }, item_field_class: BandField
      connection :albums, -> { Models::Album.all  }, item_field_class: AlbumField
      connection :songs,  -> { Models::Song.all   }, item_field_class: SongField
      connection :roles,  -> { Models::Role.all   }, item_field_class: RoleField

      call :person, -> id_or_slug { Models::Person[id_or_slug] }, returns: PersonField
      call :band,   -> id_or_slug { Models::Band[id_or_slug]   }, returns: BandField
      call :album,  -> id_or_slug { Models::Album[id_or_slug]  }, returns: AlbumField
      call :song,   -> id_or_slug { Models::Song[id_or_slug]   }, returns: SongField
      call :role,   -> id_or_slug { Models::Role[id_or_slug]   }, returns: RoleField
    end
  end
end
