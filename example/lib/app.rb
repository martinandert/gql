require 'active_support'
require 'active_record'
require 'gql'

module App
  extend ActiveSupport::Autoload

  CONNECTION_SPEC = { adapter: 'sqlite3', database: 'db/app.sqlite3' }

  autoload :Client

  module Graph
    extend ActiveSupport::Autoload

    autoload :AlbumNode
    autoload :BandNode
    autoload :DateNode
    autoload :DurationNode
    autoload :ListNode
    autoload :ModelNode
    autoload :PersonNode
    autoload :RoleNode
    autoload :RootNode
    autoload :SongNode

    GQL.field_types.update date: DateNode, duration: DurationNode
    GQL.default_list_class = ListNode
    GQL.root_node_class = RootNode
  end

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

  extend(Module.new {
    def connect
      ActiveRecord::Base.establish_connection CONNECTION_SPEC
      ActiveRecord::Base.connection
    end

    def query(*args)
      GQL.execute(*args)
    end
  })
end
