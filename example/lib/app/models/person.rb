module App
  module Models
    class Person < ActiveRecord::Base
      include Concerns::HasSlug

      has_many :memberships, :foreign_key => 'member_id'
      has_many :bands_as_member, :through => :memberships, :source => :band
      has_many :membership_roles, :through => :memberships
      has_many :roles_in_bands, :through => :membership_roles, :source => :role

      has_many :attributions, :foreign_key => 'writer_id'
      has_many :songs_as_writer, :through => :attributions, :source => :song

      validates :first_name, :last_name, :presence => true

      default_scope { order(:last_name, :first_name) }

      def name
        "#{first_name} #{last_name}"
      end
    end
  end
end
