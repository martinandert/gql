module App
  module Models
    class Membership < ActiveRecord::Base
      belongs_to :band
      belongs_to :member, :class_name => 'Person'

      has_many :membership_roles
      has_many :roles, :through => :membership_roles

      validates :band, :member, :started_year, presence: true
      validates :started_year, :ended_year, numericality: { only_integer: true, greater_than: 1900, allow_blank: true }
      validates :member, uniqueness: { scope: :band, allow_blank: true }
    end
  end
end
