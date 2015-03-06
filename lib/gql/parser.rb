#
# DO NOT MODIFY!!!!
# This file is automatically generated by Racc 1.4.12
# from Racc grammer file "".
#

require 'racc/parser.rb'


require 'active_support/json'
require 'active_support/core_ext/object/blank'
require 'active_support/core_ext/object/try'
require 'active_support/core_ext/object/json'

module GQL
  class Parser < Racc::Parser

module_eval(<<'...end parser.y/module_eval...', 'parser.y', 134)

  class Query < Struct.new(:node, :variables)
    def as_json(*)
      {
        type:       'query',
        node:       node.as_json,
        variables:  variables.as_json
      }
    end
  end

  class Call < Struct.new(:id, :arguments, :call, :object)
    def as_json(*)
      {
        type:       'call',
        id:         id.as_json,
        arguments:  arguments,
        call:       call.as_json,
        object:     object.as_json
      }
    end
  end

  class Object < Struct.new(:fields)
    def as_json(*)
      {
        type:     'object',
        fields:   fields.as_json
      }
    end
  end

  class Field < Struct.new(:id, :alias_id, :call, :object)
    def as_json(*)
      {
        type:     'field',
        id:       id.as_json,
        alias_id: alias_id.as_json,
        call:     call.as_json,
        object:   object.as_json
      }
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
...end parser.y/module_eval...
##### State transition tables begin ###

racc_action_table = [
    37,    33,    34,    35,    36,    37,    33,    34,    35,    36,
    40,    30,    70,     6,    12,    13,    30,    31,    56,    37,
    69,    22,    31,    37,    33,    34,    35,    36,    47,     7,
    46,    52,    41,    51,    30,    49,    67,     6,    66,    12,
    31,    37,    33,    34,    35,    36,    37,    33,    34,    35,
    36,    13,    30,    60,    61,     6,    12,    30,    31,     6,
    15,    13,    17,    31,    37,    33,    34,    35,    36,     6,
    20,    38,    13,    13,    51,    30,    13,    13,    68,    51,
    37,    31 ]

racc_action_check = [
    31,    31,    31,    31,    31,    15,    15,    15,    15,    15,
    19,    31,    57,     0,    19,    12,    15,    31,    31,    30,
    57,    12,    15,    20,    20,    20,    20,    20,    21,     1,
    21,    30,    20,    24,    20,    24,    53,    20,    53,    24,
    20,    61,    61,    61,    61,    61,    68,    68,    68,    68,
    68,     2,    61,    42,    42,    61,     2,    68,    61,     3,
     5,     6,     7,    68,    70,    70,    70,    70,    70,     8,
    11,    16,    40,    47,    48,    70,    49,    51,    55,    64,
    67,    70 ]

racc_action_pointer = [
    -3,    29,    43,    43,   nil,    45,    53,    62,    53,   nil,
   nil,    60,     7,   nil,   nil,     3,    54,   nil,   nil,     1,
    21,    16,   nil,   nil,    26,   nil,   nil,   nil,   nil,   nil,
    17,    -2,   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,
    64,   nil,    42,   nil,   nil,   nil,   nil,    65,    67,    68,
   nil,    69,   nil,    24,   nil,    60,   nil,     0,   nil,   nil,
   nil,    39,   nil,   nil,    72,   nil,   nil,    78,    44,   nil,
    62,   nil,   nil,   nil,   nil,   nil ]

racc_action_default = [
   -25,   -51,   -51,   -26,   -27,   -51,   -51,   -51,   -25,    -2,
    -3,    -7,   -51,   -50,   -28,   -51,   -51,    76,    -1,    -6,
   -51,   -51,   -15,   -17,   -23,   -29,   -31,   -32,   -33,   -34,
   -51,   -51,   -44,   -45,   -46,   -47,   -48,   -49,   -30,    -4,
   -51,    -8,   -51,   -11,   -12,   -13,   -14,   -51,   -21,   -51,
   -20,   -51,   -35,   -51,   -38,   -51,   -40,   -51,   -43,    -5,
    -9,   -51,   -16,   -18,   -22,   -24,   -36,   -51,   -51,   -41,
   -51,   -10,   -19,   -37,   -39,   -42 ]

racc_goto_table = [
    26,     9,    16,    43,    44,    54,    50,    10,    24,     2,
     1,     8,    55,    19,    42,    23,    58,    18,    21,    14,
    25,    53,    57,   nil,    39,   nil,   nil,   nil,   nil,    48,
    63,   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,    59,
   nil,   nil,    73,    24,    71,    44,    72,    65,    64,    55,
    62,   nil,   nil,    74,   nil,    75 ]

racc_goto_check = [
    11,     4,     6,     9,    10,    22,    14,     5,     6,     2,
     1,     3,    23,     7,     8,    13,    11,     2,    12,    16,
    17,    21,    24,   nil,     5,   nil,   nil,   nil,   nil,     5,
    14,   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,     4,
   nil,   nil,    22,     6,     9,    10,    14,     6,     4,    23,
    13,   nil,   nil,    11,   nil,    11 ]

racc_goto_pointer = [
   nil,    10,     9,     9,    -1,     5,    -4,     2,    -6,   -17,
   -16,   -15,     6,     3,   -18,   nil,    16,     5,   nil,   nil,
   nil,    -9,   -25,   -18,    -9 ]

racc_goto_default = [
   nil,   nil,   nil,   nil,   nil,   nil,    11,   nil,   nil,   nil,
     5,    45,   nil,   nil,   nil,     3,     4,   nil,    27,    28,
    29,   nil,   nil,    32,   nil ]

racc_reduce_table = [
  0, 0, :racc_error,
  3, 22, :_reduce_1,
  1, 24, :_reduce_none,
  1, 24, :_reduce_none,
  3, 25, :_reduce_4,
  4, 25, :_reduce_5,
  2, 25, :_reduce_6,
  0, 28, :_reduce_7,
  2, 28, :_reduce_8,
  3, 28, :_reduce_9,
  3, 29, :_reduce_10,
  1, 29, :_reduce_11,
  1, 30, :_reduce_none,
  1, 30, :_reduce_none,
  3, 26, :_reduce_14,
  2, 26, :_reduce_15,
  3, 33, :_reduce_16,
  1, 33, :_reduce_17,
  3, 34, :_reduce_18,
  4, 34, :_reduce_19,
  2, 34, :_reduce_20,
  2, 34, :_reduce_21,
  3, 34, :_reduce_22,
  1, 34, :_reduce_23,
  2, 35, :_reduce_24,
  0, 23, :_reduce_25,
  1, 23, :_reduce_none,
  1, 36, :_reduce_none,
  2, 36, :_reduce_28,
  3, 37, :_reduce_29,
  3, 31, :_reduce_30,
  1, 38, :_reduce_none,
  1, 32, :_reduce_none,
  1, 32, :_reduce_none,
  1, 32, :_reduce_none,
  2, 39, :_reduce_35,
  3, 39, :_reduce_36,
  3, 42, :_reduce_37,
  1, 42, :_reduce_none,
  3, 43, :_reduce_39,
  2, 40, :_reduce_40,
  3, 40, :_reduce_41,
  3, 45, :_reduce_42,
  1, 45, :_reduce_43,
  1, 41, :_reduce_none,
  1, 41, :_reduce_45,
  1, 41, :_reduce_46,
  1, 41, :_reduce_47,
  1, 41, :_reduce_48,
  1, 44, :_reduce_49,
  1, 27, :_reduce_50 ]

racc_reduce_n = 51

racc_shift_n = 76

racc_token_table = {
  false => 0,
  :error => 1,
  :STRING => 2,
  :NUMBER => 3,
  :TRUE => 4,
  :FALSE => 5,
  :NULL => 6,
  :AS => 7,
  :IDENT => 8,
  "." => 9,
  "(" => 10,
  ")" => 11,
  "," => 12,
  "{" => 13,
  "}" => 14,
  "=" => 15,
  "<" => 16,
  ">" => 17,
  ":" => 18,
  "[" => 19,
  "]" => 20 }

racc_nt_base = 21

racc_use_result_var = true

Racc_arg = [
  racc_action_table,
  racc_action_check,
  racc_action_default,
  racc_action_pointer,
  racc_goto_table,
  racc_goto_check,
  racc_goto_default,
  racc_goto_pointer,
  racc_nt_base,
  racc_reduce_table,
  racc_token_table,
  racc_shift_n,
  racc_reduce_n,
  racc_use_result_var ]

Racc_token_to_s_table = [
  "$end",
  "error",
  "STRING",
  "NUMBER",
  "TRUE",
  "FALSE",
  "NULL",
  "AS",
  "IDENT",
  "\".\"",
  "\"(\"",
  "\")\"",
  "\",\"",
  "\"{\"",
  "\"}\"",
  "\"=\"",
  "\"<\"",
  "\">\"",
  "\":\"",
  "\"[\"",
  "\"]\"",
  "$start",
  "query",
  "variables",
  "root",
  "call",
  "object",
  "identifier",
  "arguments",
  "argument_list",
  "argument",
  "variable_identifier",
  "json_value",
  "field_list",
  "field",
  "alias_identifier",
  "variable_list",
  "variable",
  "variable_value",
  "obj",
  "array",
  "scalar",
  "pairs",
  "pair",
  "string",
  "values" ]

Racc_debug_parser = false

##### State transition tables end #####

# reduce 0 omitted

module_eval(<<'.,.,', 'parser.y', 4)
  def _reduce_1(val, _values, result)
      result = Query.new(val[1], val[0].merge(val[2]))  
    result
  end
.,.,

# reduce 2 omitted

# reduce 3 omitted

module_eval(<<'.,.,', 'parser.y', 13)
  def _reduce_4(val, _values, result)
       result = Call.new(val[0], val[1], nil,    val[2])   
    result
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 14)
  def _reduce_5(val, _values, result)
       result = Call.new(val[0], val[1], val[3], nil   )   
    result
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 15)
  def _reduce_6(val, _values, result)
       result = Call.new(val[0], val[1], nil,    nil   )   
    result
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 19)
  def _reduce_7(val, _values, result)
       result = []       
    result
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 20)
  def _reduce_8(val, _values, result)
       result = []       
    result
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 21)
  def _reduce_9(val, _values, result)
       result = val[1]   
    result
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 25)
  def _reduce_10(val, _values, result)
       result.push val[2]    
    result
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 26)
  def _reduce_11(val, _values, result)
       result = val          
    result
  end
.,.,

# reduce 12 omitted

# reduce 13 omitted

module_eval(<<'.,.,', 'parser.y', 35)
  def _reduce_14(val, _values, result)
       result = Object.new(val[1])   
    result
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 36)
  def _reduce_15(val, _values, result)
       result = Object.new([]    )   
    result
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 40)
  def _reduce_16(val, _values, result)
       result.push val[2]    
    result
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 41)
  def _reduce_17(val, _values, result)
       result = val          
    result
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 45)
  def _reduce_18(val, _values, result)
       result = Field.new(val[0], val[2], nil,    val[1])   
    result
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 46)
  def _reduce_19(val, _values, result)
       result = Field.new(val[0], val[3], val[2], nil   )   
    result
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 47)
  def _reduce_20(val, _values, result)
       result = Field.new(val[0], val[1], nil,    nil   )   
    result
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 48)
  def _reduce_21(val, _values, result)
       result = Field.new(val[0], nil,    nil,    val[1])   
    result
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 49)
  def _reduce_22(val, _values, result)
       result = Field.new(val[0], nil,    val[2], nil   )   
    result
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 50)
  def _reduce_23(val, _values, result)
       result = Field.new(val[0], nil,    nil,    nil   )   
    result
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 54)
  def _reduce_24(val, _values, result)
       result = val[1]   
    result
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 58)
  def _reduce_25(val, _values, result)
       result = {}   
    result
  end
.,.,

# reduce 26 omitted

# reduce 27 omitted

module_eval(<<'.,.,', 'parser.y', 64)
  def _reduce_28(val, _values, result)
       result.update val[1]    
    result
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 68)
  def _reduce_29(val, _values, result)
       result = { val[0] => val[2] }     
    result
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 72)
  def _reduce_30(val, _values, result)
       result = val[1]   
    result
  end
.,.,

# reduce 31 omitted

# reduce 32 omitted

# reduce 33 omitted

# reduce 34 omitted

module_eval(<<'.,.,', 'parser.y', 86)
  def _reduce_35(val, _values, result)
       result = {}       
    result
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 87)
  def _reduce_36(val, _values, result)
       result = val[1]   
    result
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 91)
  def _reduce_37(val, _values, result)
       result.update val[2]    
    result
  end
.,.,

# reduce 38 omitted

module_eval(<<'.,.,', 'parser.y', 96)
  def _reduce_39(val, _values, result)
       result = { val[0] => val[2] }    
    result
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 100)
  def _reduce_40(val, _values, result)
       result = []       
    result
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 101)
  def _reduce_41(val, _values, result)
       result = val[1]   
    result
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 105)
  def _reduce_42(val, _values, result)
       result.push val[2]    
    result
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 106)
  def _reduce_43(val, _values, result)
       result = val          
    result
  end
.,.,

# reduce 44 omitted

module_eval(<<'.,.,', 'parser.y', 111)
  def _reduce_45(val, _values, result)
       result = convert_number(val[0])   
    result
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 112)
  def _reduce_46(val, _values, result)
       result = true                     
    result
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 113)
  def _reduce_47(val, _values, result)
       result = false                    
    result
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 114)
  def _reduce_48(val, _values, result)
       result = nil                      
    result
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 118)
  def _reduce_49(val, _values, result)
       result = unescape_string(val[0])  
    result
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 121)
  def _reduce_50(val, _values, result)
       result = val[0].to_sym    
    result
  end
.,.,

def _reduce_none(val, _values, result)
  val[0]
end

  end   # class Parser
  end   # module GQL
