module App
  module Graph
    class BandField < ModelField
      connection :memberships,  item_class: MembershipField
      connection :members,      item_class: PersonField
      connection :albums,       item_class: AlbumField
      connection :songs,        item_class: SongField
    end
  end
end
