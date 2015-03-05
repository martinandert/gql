class GQL::Parser
token STRING NUMBER TRUE FALSE NULL AS IDENT
rule
  root
    : variables node variables    {  result = Root.new(val[1], val[0].merge(val[2]))  }
    ;

  node
    : call                  {  result = Node.new(val[0], nil   )  }
    | '{' field_list '}'    {  result = Node.new(nil,    val[1])  }
    ;

  call
    : identifier arguments fields       {   result = Call.new(val[0], val[1], nil,    val[2].presence)   }
    | identifier arguments '.' call     {   result = Call.new(val[0], val[1], val[3], nil            )   }
    | identifier arguments              {   result = Call.new(val[0], val[1], nil,    nil            )   }
    ;

  arguments
    : /* empty */               {   result = []       }
    | '(' ')'                   {   result = []       }
    | '(' argument_list ')'     {   result = val[1]   }
    ;

  argument_list
    : argument_list ',' argument    {   result.push val[2]    }
    | argument                      {   result = val          }
    ;

  argument
    : variable_identifier
    | json_value
    ;

  fields
    : '{' '}'                 {   result = []       }
    | '{' field_list '}'      {   result = val[1]   }
    ;

  field_list
    : field_list ',' field    {   result.push val[2]    }
    | field                   {   result = val          }
    ;

  field
    : identifier fields alias_identifier      {   result = Field.new(val[0], val[2], nil,    val[1].presence)   }
    | identifier '.' call alias_identifier    {   result = Field.new(val[0], val[3], val[2], nil            )   }
    | identifier alias_identifier             {   result = Field.new(val[0], val[1], nil,    nil            )   }
    | identifier fields                       {   result = Field.new(val[0], nil,    nil,    val[1].presence)   }
    | identifier '.' call                     {   result = Field.new(val[0], nil,    val[2], nil            )   }
    | identifier                              {   result = Field.new(val[0], nil,    nil,    nil            )   }
    ;

  alias_identifier
    : AS identifier             {   result = val[1]   }
    ;

  variables
    : /* empty */               {   result = {}   }
    | variable_list
    ;

  variable_list
    : variable
    | variable_list variable    {   result.update val[1]    }
    ;

  variable
    : variable_identifier '=' variable_value    {   result = { val[0] => val[2] }     }
    ;

  variable_identifier
    : '<' identifier '>'    {   result = val[1]   }
    ;

  variable_value
    : json_value
    ;

  json_value
    : object
    | array
    | scalar
    ;

  object
    : '{' '}'         {   result = {}       }
    | '{' pairs '}'   {   result = val[1]   }
    ;

  pairs
    : pairs ',' pair    {   result.update val[2]    }
    | pair
    ;

  pair
    : string ':' json_value   {   result = { val[0] => val[2] }    }
    ;

  array
    : '[' ']'          {   result = []       }
    | '[' values ']'   {   result = val[1]   }
    ;

  values
    : values ',' json_value   {   result.push val[2]    }
    | json_value              {   result = val          }
    ;

  scalar
    : string
    | NUMBER      {   result = convert_number(val[0])   }
    | TRUE        {   result = true                     }
    | FALSE       {   result = false                    }
    | NULL        {   result = nil                      }
    ;

  string
    : STRING      {   result = unescape_string(val[0])  }

  identifier
    : IDENT       {   result = val[0].to_sym    }
    ;
end

---- header

require 'json'
require 'active_support/core_ext/object/blank'

---- inner

  Root  = Struct.new(:node, :variables)
  Node  = Struct.new(:call, :fields)
  Field = Struct.new(:id, :alias_id, :call, :fields)
  Call  = Struct.new(:id, :arguments, :call, :fields)

  UNESCAPE_MAP = Hash.new { |h, k| h[k] = k.chr }

  UNESCAPE_MAP.update(
    ?"  => '"',
    ?\\ => '\\',
    ?/  => '/',
    ?b  => "\b",
    ?f  => "\f",
    ?n  => "\n",
    ?r  => "\r",
    ?t  => "\t",
    ?u  => nil,
  )

  EMPTY_8BIT_STRING = ''

  if String.method_defined? :encode
    EMPTY_8BIT_STRING.force_encoding Encoding::ASCII_8BIT
  end

  def initialize(tokenizer)
    super()

    @tokenizer = tokenizer
  end

  def next_token
    @tokenizer.next_token
  end

  def parse
    do_parse
  end

  def on_error(token, value, vstack)
    raise Errors::SyntaxError.new(value, token_to_str(token))
  end

  private
    def unescape_string(str)
      string = str.gsub(%r((?:\\[\\bfnrt"/]|(?:\\u(?:[A-Fa-f\d]{4}))+|\\[\x20-\xff]))n) do |c|
        if u = UNESCAPE_MAP[$&[1]]
          u
        else # \uXXXX
          bytes = EMPTY_8BIT_STRING.dup
          i = 0

          while c[6 * i] == ?\\ && c[6 * i + 1] == ?u
            bytes << c[6 * i + 2, 2].to_i(16) << c[6 * i + 4, 2].to_i(16)
            i += 1
          end

          JSON.iconv('utf-8', 'utf-16be', bytes)
        end
      end

      if string.respond_to? :force_encoding
        string.force_encoding ::Encoding::UTF_8
      end

      string
    end

    def convert_number(str)
      str.count('.') > 0 ? str.to_f : str.to_i
    end
