class GQL::Parser
token STRING NUMBER TRUE FALSE NULL AS IDENT
rule
  query
    : variables call variables    {  result = QueryNode.new(val[1], convert_variables(val[0], val[2]))  }
    ;

  call
    : identifier arguments fields       {   result = CallNode.new(val[0], val[1], nil, val[2].presence)   }
    | identifier arguments sub_call     {   result = CallNode.new(val[0], val[1], val[2], nil)            }
    | identifier arguments              {   result = CallNode.new(val[0], val[1], nil, nil)               }
    ;

  sub_call
    : '.' call    {   result = val[1]   }
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
    | json_text
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
    : identifier fields alias_identifier      {   result = FieldNode.new(val[0], val[2], nil,    val[1].presence)   }
    | identifier sub_call alias_identifier    {   result = FieldNode.new(val[0], val[2], val[1], nil)               }
    | identifier alias_identifier             {   result = FieldNode.new(val[0], val[1], nil,    nil)               }
    | identifier fields                       {   result = FieldNode.new(val[0], nil,    nil,    val[1].presence)   }
    | identifier sub_call                     {   result = FieldNode.new(val[0], nil,    val[1], nil)               }
    | identifier                              {   result = FieldNode.new(val[0], nil,    nil,    nil)               }
    ;

  alias_identifier
    : AS identifier             {   result = val[1]       }
    ;

  variables
    : /* empty */               {   result = []           }
    | variable_list             {   result = val[0]       }
    ;

  variable_list
    : variable                  {   result = val }
    | variable_list variable    {   result.push val[1]    }
    ;

  variable
    : variable_identifier '=' variable_value    {   result = [val[0], val[2]]     }
    ;

  variable_identifier
    : '<' identifier '>'    {   result = val[1]   }
    ;

  variable_value
    : json_text
    ;

  json_text
    : json_value     {   result = @json.result   }

  json_value
    : object
    | array
    | scalar
    ;

  object
    : start_object end_object
    | start_object pairs end_object
    ;

  start_object : '{'    {   @json.start_object    } ;
  end_object   : '}'    {   @json.end_object      } ;

  pairs
    : pairs ',' pair
    | pair
    ;

  pair
    : string ':' json_value
    ;

  array
    : start_array end_array
    | start_array values end_array
    ;

  start_array  : '['    {   @json.start_array     } ;
  end_array    : ']'    {   @json.end_array       } ;

  values
    : values ',' json_value
    | json_value
    ;

  scalar
    : string
    | literal     {   @json.scalar val[0]   }
    ;

  string
    : STRING      {   @json.scalar unescape_string(val[0])   }
    ;

  literal
    : NUMBER      {   result = convert_number(val[0])   }
    | TRUE        {   result = true                     }
    | FALSE       {   result = false                    }
    | NULL        {   result = nil                      }
    ;

  identifier
    : IDENT       {   result = val[0].to_sym    }
    ;
end

---- header

require 'json'
require 'active_support/core_ext/object/blank'

---- inner

  class QueryNode < Struct.new(:call, :variables)
  end

  class FieldNode < Struct.new(:name, :alias_name, :call, :fields)
  end

  class CallNode < Struct.new(:name, :arguments, :call, :fields)
  end

  class JSONHandler
    attr_reader :stack

    def initialize
      clear
    end

    def start_object
      push [:hash]
    end

    def start_array
      push [:array]
    end

    def end_array
      @stack.pop
    end

    alias :end_object :end_array

    def scalar(s)
      @stack.last << [:scalar, s]
    end

    def push(o)
      @stack.last << o
      @stack << o
    end

    def result
      root = @stack.first.last
      value = process(root.first, root.drop(1))
      clear
      value
    end

    private
      def clear
        @stack = [[:json]]
      end

      def process(type, rest)
        case type
        when :array
          rest.map { |x| process(x.first, x.drop(1)) }
        when :hash
          Hash[rest.map { |x|
            process(x.first, x.drop(1))
          }.each_slice(2).to_a]
        when :scalar
          rest.first
        end
      end
  end

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
    @json = JSONHandler.new
    do_parse
  end

  def on_error(token, value, vstack)
    raise Errors::ParseError.new(value, token_to_str(token))
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

    def convert_variables(arr1, arr2)
      Hash[*arr1.flatten(1)].merge Hash[*arr2.flatten(1)]
    end
