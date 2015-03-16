module App
  module Models
    class MembershipRole < ActiveRecord::Base
      belongs_to :membership
      belongs_to :role
    end
  end
end
