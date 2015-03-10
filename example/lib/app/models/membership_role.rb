module App
  module Models
    class MembershipRole < ActiveRecord::Base
      belongs_to :membership
      belongs_to :role

      validates :membership, :role, :presence => true
    end
  end
end
