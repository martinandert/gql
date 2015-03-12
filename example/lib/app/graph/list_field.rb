module App
  module Graph
    class ListField < GQL::Field
      # MODEL_NODE_MAPPING = {
      #   Models::Person => PersonField,
      #   Models::Band => BandField,
      #   Models::Album => AlbumField,
      #   Models::Song => SongField,
      #   Models::Role => RoleField
      # }.freeze

      number :count
      boolean :any, -> { target.any? }

      call :skip, -> size { target.offset(size) }
      call :take, -> size { target.limit(size) }

      # TODO :returns with a model map
      # call :first, returns: MODEL_NODE_MAPPING
    end
  end
end
