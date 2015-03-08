module GQL
  autoload :Array,      'gql/array'
  autoload :Boolean,    'gql/boolean'
  autoload :Call,       'gql/call'
  autoload :Config,     'gql/config'
  autoload :Connection, 'gql/connection'
  autoload :Error,      'gql/errors'
  autoload :Executor,   'gql/executor'
  autoload :List,       'gql/list'
  autoload :Node,       'gql/node'
  autoload :Number,     'gql/number'
  autoload :Object,     'gql/object'
  autoload :Parser,     'gql/parser'
  autoload :Raw,        'gql/raw'
  autoload :String,     'gql/string'
  autoload :TestCase,   'gql/test_case'
  autoload :VERSION,    'gql/version'

  module Errors
    autoload :InvalidNodeClass,   'gql/errors'
    autoload :ScanError,          'gql/errors'
    autoload :SyntaxError,        'gql/errors'
    autoload :UndefinedCall,      'gql/errors'
    autoload :UndefinedField,     'gql/errors'
    autoload :UndefinedNodeClass, 'gql/errors'
    autoload :UndefinedRoot,      'gql/errors'
    autoload :UndefinedFieldType, 'gql/errors'
  end

  module Schema
    autoload :Call,         'gql/schema/call'
    autoload :Field,        'gql/schema/field'
    autoload :List,         'gql/schema/list'
    autoload :Parameter,    'gql/schema/parameter'
    autoload :Placeholder,  'gql/schema/placeholder'
    autoload :Root,         'gql/schema/root'
  end

  extend(Module.new {
    def config
      Thread.current[:gql_config] ||= Config.new
    end

    %w(root_node_class field_types default_list_class).each do |method|
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

  self.field_types.update(
    array:      Array,
    boolean:    Boolean,
    connection: Connection,
    number:     Number,
    object:     Object,
    string:     String
  )
end
