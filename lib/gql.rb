module GQL
  autoload :Call,       'gql/call'
  autoload :Config,     'gql/config'
  autoload :Connection, 'gql/connection'
  autoload :Executor,   'gql/executor'
  autoload :Field,      'gql/field'
  autoload :Node,       'gql/node'
  autoload :Parser,     'gql/parser'
  autoload :Tokenizer,  'gql/tokenizer'
  autoload :VERSION,    'gql/version'

  module Errors
    autoload :InvalidNodeClass,   'gql/errors'
    autoload :ParseError,         'gql/errors'
    autoload :UndefinedCall,      'gql/errors'
    autoload :UndefinedField,     'gql/errors'
    autoload :UndefinedNodeClass, 'gql/errors'
    autoload :UndefinedRoot,      'gql/errors'
    autoload :UndefinedFieldType, 'gql/errors'
  end

  module Fields
    autoload :Array,        'gql/fields/array'
    autoload :Boolean,      'gql/fields/boolean'
    autoload :Connection,   'gql/fields/connection'
    autoload :Float,        'gql/fields/float'
    autoload :Integer,      'gql/fields/integer'
    autoload :Object,       'gql/fields/object'
    autoload :String,       'gql/fields/string'
  end

  extend(Module.new {
    def config
      Thread.current[:gql_config] ||= Config.new
    end

    %w(root_node_class field_types).each do |method|
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
      ast = parse(input)

      executor = Executor.new(ast)
      executor.execute context
    end

    def parse(input)
      input = input.read if input.respond_to?(:read)

      tokenizer = Tokenizer.new
      tokenizer.scan_setup input

      parser = Parser.new(tokenizer)
      parser.parse
    end

    def tokenize(input)
      input = input.read if input.respond_to?(:read)

      tokenizer = Tokenizer.new
      tokenizer.scan_setup input

      while token = tokenizer.next_token
        yield token
      end
    end
  })

  self.field_types.update(
    array:      Fields::Array,
    boolean:    Fields::Boolean,
    connection: Fields::Connection,
    float:      Fields::Float,
    integer:    Fields::Integer,
    object:     Fields::Object,
    string:     Fields::String
  )
end
