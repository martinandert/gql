module App
  module Models
    module Concerns
      module HasSlug
        extend ActiveSupport::Concern

        included do
          validates :slug,
              presence:   true,
              format:     /\A[a-z][a-z0-9\-]*[a-z0-9]\z/,
              uniqueness: { case_sensitive: false }
        end

        module ClassMethods
          def [](value)
            value  = value.to_s
            column = value =~ /\A\d+\z/ ? :id : :slug

            where(column => value).take!
          end
        end
      end
    end
  end
end
