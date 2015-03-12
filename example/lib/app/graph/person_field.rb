module App
  module Graph
    class PersonField < ModelField
      string :first_name
      string :last_name

      connection :memberships,      item_field_class: MembershipField
      connection :bands_as_member,  item_field_class: BandField
      connection :songs_as_writer,  item_field_class: SongField
      connection :roles_in_bands,   item_field_class: RoleField
    end
  end
end
