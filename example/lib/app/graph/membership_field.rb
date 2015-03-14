module App
  module Graph
    class MembershipField < GQL::Field
      cursor :id

      number :id
      string :type, -> { target.class.name.split('::').last.downcase }
      object :band,   class: BandField
      object :member, class: PersonField
      number :started_year
      number :ended_year

      string :band_name,   -> { target.band.name }
      string :member_name, -> { target.member.name }
    end
  end
end