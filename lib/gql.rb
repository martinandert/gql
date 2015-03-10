require 'active_support/dependencies/autoload'
require 'gql/version'

module GQL
  extend ActiveSupport::Autoload

  autoload :Array
  autoload :Boolean
  autoload :Call
  autoload :Config
  autoload :Connection
  autoload :Error, 'gql/errors'
  autoload :Executor
  autoload :Node
  autoload :Number
  autoload :Object
  autoload :Parser
  autoload :Raw
  autoload :String
  autoload :TestCase

  module Errors
    extend ActiveSupport::Autoload

    autoload_at 'gql/errors' do
      autoload :CallNotFound
      autoload :FieldNotFound
      autoload :InvalidNodeClass
      autoload :NoMethodError
      autoload :RootClassNotSet
      autoload :ScanError
      autoload :SyntaxError
      autoload :UndefinedNodeClass
    end
  end

  module Schema
    extend ActiveSupport::Autoload

    autoload :Call
    autoload :Field
    autoload :List
    autoload :Parameter
    autoload :Placeholder
    autoload :Root
  end

  extend(Module.new {
    def config
      Thread.current[:gql_config] ||= Config.new
    end

    def config=(value)
      Thread.current[:gql_config] = value
    end

    %w(root_node_class root_target_proc field_types
       default_list_class default_field_proc
       default_call_proc).each do |method|
      module_eval <<-DELEGATORS, __FILE__, __LINE__ + 1
        def #{method}
          config.#{method}
        end

        def #{method}=(value)
          config.#{method} = (value)
        end
      DELEGATORS
    end

    def execute(input, context = {})
      query = parse(input)

      executor = Executor.new(query)
      executor.execute context
    end

    def parse(input)
      Parser.new(input).parse
    end

    def tokenize(input)
      parser = Parser.new(input)

      [].tap do |result|
        while token = parser.next_token
          result << token
          yield token if block_given?
        end
      end
    end
  })
end
