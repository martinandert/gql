require 'active_support'
require 'active_record'
require 'gql'

module App
  extend ActiveSupport::Autoload

  autoload :Client
  autoload :Helper

  module Models
    extend ActiveSupport::Autoload

    autoload :Album
    autoload :Attribution
    autoload :Band
    autoload :Membership
    autoload :MembershipRole
    autoload :Person
    autoload :Role
    autoload :Song

    module Concerns
      extend ActiveSupport::Autoload

      autoload :HasSlug
    end
  end

  module Graph
    extend ActiveSupport::Autoload

    autoload :AlbumField
    autoload :BandField
    autoload :DateField
    autoload :DurationField
    autoload :ListField
    autoload :MembershipField
    autoload :ModelField
    autoload :PersonField
    autoload :RoleField
    autoload :RootField
    autoload :SongField

    GQL.field_types.update date: DateField, duration: DurationField
    GQL.default_list_class = ListField
    GQL.root_class = RootField
  end
end
