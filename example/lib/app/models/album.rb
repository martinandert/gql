module App
  module Models
    class Album < ActiveRecord::Base
      include Concerns::HasSlug

      belongs_to :band

      has_many :songs

      validates :band, :title, :released_on, :presence => true

      default_scope { order(:released_on) }

      alias_attribute :name, :title
    end
  end
end
