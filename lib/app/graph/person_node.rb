module App
  module Graph
    class PersonNode < ModelNode
      string :first_name
      string :last_name

      connection :bands_as_member,  item_class: BandNode
      connection :songs_as_writer,  item_class: SongNode
      connection :roles_in_bands,   item_class: RoleNode
    end
  end
end
