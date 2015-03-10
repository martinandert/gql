module App
  module Models
    class Song < ActiveRecord::Base
      belongs_to :album

      has_many :attributions
      has_many :writers, :through => :attributions, :class_name => 'Person'

      validates :slug, :album, :title, :duration, :position, :presence => true
      validates :slug, :format => /\A[a-z][a-z0-9\-]*[a-z0-9]\z/, :uniqueness => { :case_sensitive => false }, :allow_blank => true
      validates :duration, :position, :numericality => { :only_integer => true, :greater_than => 0 }, :allow_blank => true
      validates :position, :uniqueness => { :scope => :album }, :allow_blank => true
    end
  end
end
