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
          def [](id)
            clause = id.to_s =~ /\A\d+\z/ ? { id: id } : { slug: id.to_s }
            where(clause).take!
          end
        end
      end
    end
  end
end
