module GQL
  autoload :Call,       'gql/call'
  autoload :Connection, 'gql/connection'
  autoload :Executor,   'gql/executor'
  autoload :Field,      'gql/field'
  autoload :Node,       'gql/node'
  autoload :Parser,     'gql/parser'
  autoload :Schema,     'gql/schema'
  autoload :Tokenizer,  'gql/tokenizer'
  autoload :VERSION,    'gql/version'

  module Errors
    autoload :InvalidNodeClass, 'gql/errors'
    autoload :ParseError,       'gql/errors'
    autoload :UndefinedCall,    'gql/errors'
    autoload :UndefinedField,   'gql/errors'
    autoload :UndefinedRoot,    'gql/errors'
    autoload :UndefinedType,    'gql/errors'
  end

  module Fields
    autoload :Boolean,      'gql/fields/boolean'
    autoload :Connection,   'gql/fields/connection'
    autoload :Float,        'gql/fields/float'
    autoload :Integer,      'gql/fields/integer'
    autoload :Object,       'gql/fields/object'
    autoload :String,       'gql/fields/string'
  end

  Schema.fields.update(
    boolean:    Fields::Boolean,
    connection: Fields::Connection,
    float:      Fields::Float,
    integer:    Fields::Integer,
    object:     Fields::Object,
    string:     Fields::String
  )

  extend(Module.new {
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
end
