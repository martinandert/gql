module App
  module Graph
    class ListNode < GQL::Node
      # MODEL_NODE_MAPPING = {
      #   Models::Person => PersonNode,
      #   Models::Band => BandNode,
      #   Models::Album => AlbumNode,
      #   Models::Song => SongNode,
      #   Models::Role => RoleNode
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
