module App
  module Graph
    class CreateBandMembershipCall < GQL::Call
      returns MembershipField

      def execute(person_id_or_slug, band_id_or_slug, started_year, ended_year = nil, role_ids_or_slugs = [])
        attributes = {
          band:         Models::Band[band_id_or_slug],
          member:       Models::Person[person_id_or_slug],
          started_year: started_year,
          ended_year:   ended_year,
          roles:        role_ids_or_slugs.map { |r| Models::Role[r] }
        }

        Models::Membership.create! attributes
      end
    end
  end
end
