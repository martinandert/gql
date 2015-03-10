module App
  module Models
    class Album < ActiveRecord::Base
      belongs_to :band

      has_many :songs

      validates :slug, :band, :title, :released_on, :presence => true
      validates :slug, :format => /\A[a-z][a-z0-9\-]*[a-z0-9]\z/, :uniqueness => { :case_sensitive => false }, :allow_blank => true
    end
  end
end
