module App
  module Models
    class Song < ActiveRecord::Base
      include Concerns::HasSlug

      belongs_to :album

      has_many :attributions
      has_many :writers, :through => :attributions, :class_name => 'Person'

      validates :album, :title, :duration, :track_number, :presence => true
      validates :duration, :track_number, :numericality => { :only_integer => true, :greater_than => 0 }, :allow_blank => true
      validates :track_number, :uniqueness => { :scope => :album }, :allow_blank => true

      default_scope { order(:track_number) }

      alias_attribute :name, :title

      def band
        album.band
      end
    end
  end
end
