module App
  module Graph
    class ListField < GQL::Field
      MODEL_TO_FIELD_MAPPING = {
        Models::Person      => 'App::Graph::PersonField',
        Models::Band        => 'App::Graph::BandField',
        Models::Album       => 'App::Graph::AlbumField',
        Models::Song        => 'App::Graph::SongField',
        Models::Role        => 'App::Graph::RoleField',
        Models::Membership  => 'App::Graph::MembershipField'
      }.freeze

      number :count
      boolean :any, -> { target.any? }

      call :skip, -> size { target.offset(size) }
      call :take, -> size { target.limit(size) }

      # proc given here b/c we want no arguments (-> just a single record) and raise! if not found
      call :first, -> { target.first! }, returns: MODEL_TO_FIELD_MAPPING
      call :last, ->  { target.last!  }, returns: MODEL_TO_FIELD_MAPPING
    end
  end
end
