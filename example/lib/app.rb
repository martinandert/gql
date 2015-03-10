require 'active_support'
require 'active_record'

module App
  CONNECTION_SPEC = { adapter: 'sqlite3', database: 'db/app.sqlite3' }

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
  end

  extend(Module.new {
    def connect
      ActiveRecord::Base.establish_connection CONNECTION_SPEC
      ActiveRecord::Base.connection
    end
  })
end
