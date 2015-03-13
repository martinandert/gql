module App
  module Graph
    class PersonField < ModelField
      string :first_name
      string :last_name

      connection :memberships,      item_class: MembershipField
      connection :bands_as_member,  item_class: BandField
      connection :songs_as_writer,  item_class: SongField
      connection :roles_in_bands,   item_class: RoleField
    end
  end
end
