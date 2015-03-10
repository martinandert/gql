module App
  module Models
    class Band < ActiveRecord::Base
      include Concerns::HasSlug

      has_many :memberships
      has_many :members, :through => :memberships

      has_many :albums
      has_many :songs, :through => :albums

      validates :name, :presence => true

      default_scope { order(:name) }
    end
  end
end
