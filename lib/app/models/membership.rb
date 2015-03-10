module App
  module Models
    class Membership < ActiveRecord::Base
      belongs_to :band
      belongs_to :member, :class_name => 'Person'

      validates :band, :member, :started_year, :presence => true
      validates :started_year, :ended_year, :numericality => { :only_integer => true, :greater_than => 1900 }, :allow_blank => true
    end
  end
end
