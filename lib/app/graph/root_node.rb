module App
  module Graph
    class RootNode < GQL::Node
      connection :people, -> { Models::Person.all }, item_class: PersonNode
      connection :bands,  -> { Models::Band.all   }, item_class: BandNode
      connection :albums, -> { Models::Album.all  }, item_class: AlbumNode
      connection :songs,  -> { Models::Song.all   }, item_class: SongNode
      connection :roles,  -> { Models::Role.all   }, item_class: RoleNode

      call :person, -> id_or_slug { Models::Person[id_or_slug] }, returns: PersonNode
      call :band,   -> id_or_slug { Models::Band[id_or_slug]   }, returns: BandNode
      call :album,  -> id_or_slug { Models::Album[id_or_slug]  }, returns: AlbumNode
      call :song,   -> id_or_slug { Models::Song[id_or_slug]   }, returns: SongNode
      call :role,   -> id_or_slug { Models::Role[id_or_slug]   }, returns: RoleNode
    end
  end
end
