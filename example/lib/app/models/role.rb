module App
  module Models
    class Role < ActiveRecord::Base
      include Concerns::HasSlug

      has_many :membership_roles
      has_many :memberships, :through => :membership_roles
      has_many :members, :through => :memberships

      validates :name, :presence => true, :uniqueness => true

      default_scope { order(:name) }
    end
  end
end
