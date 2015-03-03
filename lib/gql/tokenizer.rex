class GQL::Tokenizer
macro
  BLANK         \s+
  REM_IN        \/\*
  REM_OUT       \*\/
  REM           \/\/
  STRING        "(?:[^"\\]|\\(?:["\\\/bfnrt]|u[0-9a-fA-F]{4}))*"
  NUMBER        -?(?:0|[1-9]\d*)(?:\.\d+)?(?:[eE][+-]?\d+)?
  TRUE          true
  FALSE         false
  NULL          null
  IDENT         [a-zA-Z_][a-zA-Z0-9_]*
  AS            [aA][sS]

rule

# [:state]      pattern         [action]

# remarks
                {REM_IN}        { @state = :REMS; nil }
  :REMS         {REM_OUT}       { @state = nil;   nil }
  :REMS         .*(?={REM_OUT}) # ignore
                {REM}           { @state = :REM;  nil }
  :REM          \n              { @state = nil;   nil }
  :REM          .*(?=$)         # ignore

# scalars
                {STRING}        { [:STRING, text.gsub(/^"|"$/, '')] }
                {NUMBER}        { [:NUMBER, text] }
                {TRUE}          { [:TRUE, text] }
                {FALSE}         { [:FALSE, text] }
                {NULL}          { [:NULL, text] }

# keywords
                {AS}            { [:AS, text] }

# identifier
                {IDENT}         { [:IDENT, text] }

# whitespace
                {BLANK}         # ignore

# rest
                .               { [text, text] }

end
