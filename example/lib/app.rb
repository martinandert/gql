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

    autoload :AlbumNode
    autoload :BandNode
    autoload :DateNode
    autoload :DurationNode
    autoload :ListNode
    autoload :MembershipNode
    autoload :ModelNode
    autoload :PersonNode
    autoload :RoleNode
    autoload :RootNode
    autoload :SongNode

    GQL.field_types.update date: DateNode, duration: DurationNode
    GQL.default_list_class = ListNode
    GQL.root_node_class = RootNode

    extend(Module.new {
      def query(*args)
        GQL.execute(*args)
      rescue GQL::Error => exc
        exc.as_json
      end
    })
  end
end
