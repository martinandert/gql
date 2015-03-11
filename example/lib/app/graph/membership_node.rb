module App
  module Graph
    class MembershipNode < GQL::Node
      cursor :id

      number :id
      string :type, -> { target.class.name.split('::').last.downcase }
      object :band,   node_class: BandNode
      object :member, node_class: PersonNode
      number :started_year
      number :ended_year

      string :band_name,   -> { target.band.name }
      string :member_name, -> { target.member.name }
    end
  end
end
