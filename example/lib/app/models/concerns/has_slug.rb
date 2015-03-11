module App
  module Models
    module Concerns
      module HasSlug
        extend ActiveSupport::Concern

        included do
          validates :slug,
                      :presence => true,
                      :format => /\A[a-z][a-z0-9\-]*[a-z0-9]\z/,
                      :uniqueness => { :case_sensitive => false }
        end

        module ClassMethods
          def [](id_or_slug)
            where('id = ? OR slug = ?', id_or_slug, id_or_slug).take
          end
        end
      end
    end
  end
end