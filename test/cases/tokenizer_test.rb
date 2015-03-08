require 'cases/helper'
require 'json'

class TokenizerTest < GQL::TestCase
  test "token types" do
    q = <<-QUERY
      _ foo Foo _foo _Foo _1 _1foo
      "string" 'no string'
      true false null as ( ) { } < > : = ,
      0 01 1 123 -123 123.45 -123.45
      123.45e8 123.45e+8 123.45e-8 123.45E8 123.45E+8 123.45E-8
      123.45e08 123.45e+08 123.45e-08 123.45E08 123.45E+08 123.45E-08
      -123.45e8 -123.45e+8 -123.45e-8 -123.45E8 -123.45E+8 -123.45E-8
      -123.45e08 -123.45e+08 -123.45e-08 -123.45E08 -123.45E+08 -123.45E-08
    QUERY

    expected = [
      [:IDENT, "_"], [:IDENT, "foo"], [:IDENT, "Foo"], [:IDENT, "_foo"],
      [:IDENT, "_Foo"], [:IDENT, "_1"], [:IDENT, "_1foo"], [:STRING, "string"],
      ["'", "'"], [:IDENT, "no"], [:IDENT, "string"], ["'", "'"], [:TRUE, "true"],
      [:FALSE, "false"], [:NULL, "null"], [:AS, "as"], ["(", "("], [")", ")"],
      ["{", "{"], ["}", "}"], ["<", "<"], [">", ">"], [":", ":"], ["=", "="],
      [",", ","], [:NUMBER, "0"], [:NUMBER, "0"], [:NUMBER, "1"], [:NUMBER, "1"],
      [:NUMBER, "123"], [:NUMBER, "-123"], [:NUMBER, "123.45"], [:NUMBER, "-123.45"],
      [:NUMBER, "123.45e8"], [:NUMBER, "123.45e+8"], [:NUMBER, "123.45e-8"],
      [:NUMBER, "123.45E8"], [:NUMBER, "123.45E+8"], [:NUMBER, "123.45E-8"],
      [:NUMBER, "123.45e08"], [:NUMBER, "123.45e+08"], [:NUMBER, "123.45e-08"],
      [:NUMBER, "123.45E08"], [:NUMBER, "123.45E+08"], [:NUMBER, "123.45E-08"],
      [:NUMBER, "-123.45e8"], [:NUMBER, "-123.45e+8"], [:NUMBER, "-123.45e-8"],
      [:NUMBER, "-123.45E8"], [:NUMBER, "-123.45E+8"], [:NUMBER, "-123.45E-8"],
      [:NUMBER, "-123.45e08"], [:NUMBER, "-123.45e+08"], [:NUMBER, "-123.45e-08"],
      [:NUMBER, "-123.45E08"], [:NUMBER, "-123.45E+08"], [:NUMBER, "-123.45E-08"]
    ]

    assert_equal expected, GQL.tokenize(q)
  end

  test "empty query" do
    assert_equal GQL.tokenize(''), []
  end

  test "ignores comments" do
    q = <<-QUERY
      foo // end-of-line comment
      bar /* block comment */ baz
      bum /* block
           * comment *
        spanning // multiple
        lines */ bam
      bim
    QUERY

    expected = [
      [:IDENT, "foo"], [:IDENT, "bar"], [:IDENT, "baz"],
      [:IDENT, "bum"], [:IDENT, "bam"], [:IDENT, "bim"]
    ]

    assert_equal expected, GQL.tokenize(q)
  end

  test "whitespace does not matter" do
    q1 = <<-QUERY

              foo   . bar ( a ,b ,
                c, d
            )
          {
              baz
            ,    boo
          . bum  {
              123
         }    }

    QUERY

    q2 = q1.gsub(/\s*/m, '')

    assert_equal GQL.tokenize(q1), GQL.tokenize(q2)
  end

  test "raises on unclosed block comment" do
    assert_raises GQL::Errors::ScanError do
      GQL.tokenize " foo /* comment "
    end
  end

  test "strings with special chars" do
    str = "ä \" \\ \b \f \n \r \t \u01ab ƫ \u34cd 㓍 µ @"
    q = JSON.generate([str])[1..-2]

    assert_equal [[:STRING, str]], GQL.tokenize(q)
  end
end
