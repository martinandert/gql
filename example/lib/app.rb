require 'active_support'
require 'active_record'
require 'gql'

module App
  extend ActiveSupport::Autoload

  autoload :Client

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
    GQL.default_list_field_class = ListField
    GQL.root_field_class = RootField

    extend(Module.new {
      def query(*args)
        GQL.execute(*args)
      rescue GQL::Error => exc
        exc.as_json
      end
    })
  end
end
