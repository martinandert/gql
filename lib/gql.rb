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
  autoload :Field
  autoload :Number
  autoload :Object
  autoload :Parser
  autoload :Registry
  autoload :Scalar
  autoload :String
  autoload :TestCase
  autoload :Tokenizer
  autoload :Unresolved

  module Errors
    extend ActiveSupport::Autoload

    autoload_at 'gql/errors' do
      autoload :CallNotFound
      autoload :FieldClassNotSet
      autoload :FieldNotFound
      autoload :InvalidFieldClass
      autoload :NoMethodError
      autoload :RootClassNotSet
      autoload :ScanError
      autoload :SyntaxError
      autoload :VariableNotFound
    end
  end

  module Schema
    extend ActiveSupport::Autoload

    autoload :Call
    autoload :Field
    autoload :List
    autoload :Parameter
    autoload :CallerClass
  end

  extend(Module.new {
    def config
      Thread.current[:gql_config] ||= Config.new
    end

    def config=(value)
      Thread.current[:gql_config] = value
    end

    %w(root_field_class root_target_proc field_types
       default_list_field_class default_field_proc
       default_call_proc debug).each do |method|
      module_eval <<-DELEGATORS, __FILE__, __LINE__ + 1
        def #{method}
          config.#{method}
        end

        def #{method}=(value)
          config.#{method} = (value)
        end
      DELEGATORS
    end

    def execute(input, context = {}, variables = {})
      query = parse(input)

      executor = Executor.new(query)
      executor.execute context, variables
    end

    def parse(input)
      Parser.new(input).parse
    end

    def tokenize(input)
      tokenizer = Tokenizer.new
      tokenizer.scan_setup input

      [].tap do |result|
        while token = tokenizer.next_token
          result << token
          yield token if block_given?
        end
      end
    end
  })
end
