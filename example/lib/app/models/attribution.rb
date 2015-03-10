module App
  module Models
    class Attribution < ActiveRecord::Base
      belongs_to :song
      belongs_to :writer, :class_name => 'Person'

      validates :song, :writer, :presence => true
    end
  end
end
