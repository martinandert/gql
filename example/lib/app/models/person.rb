module App
  module Models
    class Person < ActiveRecord::Base
      has_many :memberships, :foreign_key => 'member_id'
      has_many :bands_as_member, :through => :memberships, :source => :band
      has_many :roles, :through => :memberships

      has_many :attributions, :foreign_key => 'writer_id'
      has_many :written_songs, :through => :attributions, :source => :song

      validates :slug, :first_name, :last_name, :presence => true
      validates :slug, :format => /\A[a-z][a-z0-9\-]*[a-z0-9]\z/, :uniqueness => { :case_sensitive => false }, :allow_blank => true
    end
  end
end
