module App
  module Graph
    class RootField < GQL::Field
      connection :people, -> { Models::Person.all }, item_class: PersonField
      connection :bands,  -> { Models::Band.all   }, item_class: BandField
      connection :albums, -> { Models::Album.all  }, item_class: AlbumField
      connection :songs,  -> { Models::Song.all   }, item_class: SongField
      connection :roles,  -> { Models::Role.all   }, item_class: RoleField

      call :person, -> id_or_slug { Models::Person[id_or_slug] }, returns: PersonField
      call :band,   -> id_or_slug { Models::Band[id_or_slug]   }, returns: BandField
      call :album,  -> id_or_slug { Models::Album[id_or_slug]  }, returns: AlbumField
      call :song,   -> id_or_slug { Models::Song[id_or_slug]   }, returns: SongField
      call :role,   -> id_or_slug { Models::Role[id_or_slug]   }, returns: RoleField

      def self.create_proc_for(model)
        -> attributes { model.create! attributes }
      end

      call :create_person,  create_proc_for(Models::Person),  returns: PersonField
      call :create_band,    create_proc_for(Models::Band),    returns: BandField
      call :create_album,   create_proc_for(Models::Album),   returns: AlbumField
      call :create_song,    create_proc_for(Models::Song),    returns: SongField
      call :create_role,    create_proc_for(Models::Role),    returns: RoleField

      call :assign_person_to_band, 'App::Graph::CreateBandMembershipCall'

      call :you, -> { context }, returns: YouField
    end
  end
end
