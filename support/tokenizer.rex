class GQL::Parser
macro
  BLANK         \s+
  REM_IN        \/\*
  REM_OUT       \*\/
  REM           \/\/
# STRING        "(?:[^"\\]|\\(?:["\\\/bfnrt]|u[0-9a-fA-F]{4}))*"
  STRING        "(?:[^"\\]|\\["\\\/bfnrt]|\\u[0-9a-fA-F]{4})*"
  NUMBER        -?(?:0|[1-9]\d*)(?:\.\d+)?(?:[eE][+-]?\d+)?
  TRUE          true
  FALSE         false
  NULL          null
  IDENT         [a-zA-Z_][a-zA-Z0-9_]*
  AS            [aA][sS]

rule

# [:state]      pattern               [action]

# remarks
                {REM_IN}              { @state = :REMS; nil }
  :REMS         {REM_OUT}             { @state = nil;   nil }
  :REMS         .*(?={REM_OUT})       # ignore (single line)
  :REMS         (.|\n)*(?={REM_OUT})  # ignore (multiline)

                {REM}                 { @state = :REM;  nil }
  :REM          \n                    { @state = nil;   nil }
  :REM          .*(?=$)               # ignore

# scalars
                {STRING}              { [:STRING, unescape_string(text)] }
                {NUMBER}              { [:NUMBER, text] }
                {TRUE}                { [:TRUE, text] }
                {FALSE}               { [:FALSE, text] }
                {NULL}                { [:NULL, text] }

# keywords
                {AS}                  { [:AS, text] }

# identifier
                {IDENT}               { [:IDENT, text] }

# whitespace
                {BLANK}               # ignore

# rest
                .                     { [text, text] }

inner
  private
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

    def unescape_string(str)
      string = str.gsub(/^"|"$/, '').gsub(%r((?:\\[\\bfnrt"/]|(?:\\u(?:[A-Fa-f\d]{4}))+|\\[\x20-\xff]))n) do |c|
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

end
