module App
  module Models
    class Attribution < ActiveRecord::Base
      belongs_to :song
      belongs_to :writer, :class_name => 'Person'
    end
  end
end
