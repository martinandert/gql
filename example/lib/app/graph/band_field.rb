module App
  module Graph
    class BandField < ModelField
      connection :memberships,  item_field_class: MembershipField
      connection :members,      item_field_class: PersonField
      connection :albums,       item_field_class: AlbumField
      connection :songs,        item_field_class: SongField
    end
  end
end
