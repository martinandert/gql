module App
  module Models
    class Band < ActiveRecord::Base
      has_many :memberships
      has_many :members, :through => :memberships

      has_many :albums
      has_many :songs, :through => :albums

      validates :slug, :name, :presence => true
      validates :slug, :format => /\A[a-z][a-z0-9\-]*[a-z0-9]\z/, :uniqueness => { :case_sensitive => false }, :allow_blank => true
    end
  end
end
