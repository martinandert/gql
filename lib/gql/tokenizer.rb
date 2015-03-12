#--
# DO NOT MODIFY!!!!
# This file is automatically generated by rex 1.0.5
# from lexical definition file "support/tokenizer.rex".
#++

require 'racc/parser'
class GQL::Tokenizer < Racc::Parser
  require 'strscan'

  class Unused < StandardError ; end

  attr_reader   :lineno
  attr_reader   :filename
  attr_accessor :state

  def scan_setup(str)
    @ss = StringScanner.new(str)
    @lineno =  1
    @state  = nil
  end

  def action
    yield
  end

  def scan_str(str)
    scan_setup(str)
    do_parse
  end
  alias :scan :scan_str

  def load_file( filename )
    @filename = filename
    open(filename, "r") do |f|
      scan_setup(f.read)
    end
  end

  def scan_file( filename )
    load_file(filename)
    do_parse
  end


  def next_token
    return if @ss.eos?
    
    # skips empty actions
    until token = _next_token or @ss.eos?; end
    token
  end

  def _next_token
    text = @ss.peek(1)
    @lineno  +=  1  if text == "\n"
    token = case @state
    when nil
      case
      when (text = @ss.scan(/\/\*/))
         action { @state = :REMS; nil }

      when (text = @ss.scan(/\/\//))
         action { @state = :REM;  nil }

      when (text = @ss.scan(/"(?:[^"\\]|\\["\\\/bfnrt]|\\u[0-9a-fA-F]{4})*"/))
         action { [:STRING, convert_json(text)] }

      when (text = @ss.scan(/-?(?:0|[1-9]\d*)(?:\.\d+)?(?:[eE][+-]?\d+)?/))
         action { [:NUMBER, text] }

      when (text = @ss.scan(/true\b/))
         action { [:TRUE, text] }

      when (text = @ss.scan(/false\b/))
         action { [:FALSE, text] }

      when (text = @ss.scan(/null\b/))
         action { [:NULL, text] }

      when (text = @ss.scan(/[aA][sS]\b/))
         action { [:AS, text] }

      when (text = @ss.scan(/[a-zA-Z_][a-zA-Z0-9_]*/))
         action { [:IDENT, text] }

      when (text = @ss.scan(/(?:[[:blank:]]|\f)+/))
        ;

      when (text = @ss.scan(/\r?\n/))
        ;

      when (text = @ss.scan(/./))
         action { [text, text] }

      else
        text = @ss.string[@ss.pos .. -1]
        raise  GQL::Errors::ScanError, "can not match: '" + text + "'"
      end  # if

    when :REMS
      case
      when (text = @ss.scan(/\*\//))
         action { @state = nil;   nil }

      when (text = @ss.scan(/.*(?=\*\/)/))
        ;

      when (text = @ss.scan(/.+(?=\n)/))
        ;

      when (text = @ss.scan(/\n/))
        ;

      else
        text = @ss.string[@ss.pos .. -1]
        raise  GQL::Errors::ScanError, "can not match: '" + text + "'"
      end  # if

    when :REM
      case
      when (text = @ss.scan(/\n/))
         action { @state = nil;   nil }

      when (text = @ss.scan(/.*(?=$)/))
        ;

      else
        text = @ss.string[@ss.pos .. -1]
        raise  GQL::Errors::ScanError, "can not match: '" + text + "'"
      end  # if

    else
      raise  GQL::Errors::ScanError, "undefined state: '" + state.to_s + "'"
    end  # case state
    token
  end  # def _next_token

  private
    require 'multi_json'
    def convert_json(str)
      MultiJson.load("[#{str}]").first
    end
end # class
