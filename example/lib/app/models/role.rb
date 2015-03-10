module App
  module Models
    class Role < ActiveRecord::Base
      has_many :membership_roles
      has_many :memberships, :through => :membership_roles
      has_many :members, :through => :memberships

      validates :name, :presence => true, :uniqueness => true
    end
  end
end
