require 'cases/helper'
require 'json'

class ParserTest < ActiveSupport::TestCase
  test "empty query" do
    assert_raises GQL::Errors::SyntaxError do
      GQL.parse ''
    end
  end

  test "only variables" do
    assert_raises GQL::Errors::SyntaxError do
      GQL.parse '<x> = 1 <y> = "foo"'
    end
  end

  test "root call" do
    actual = GQL.parse('call').as_json

    expected = {
      root: {
        id: '[root]', alias_id: nil,
        call: { id: :call, arguments: [], call: nil, fields: nil },
        fields: nil,
      },
      variables: {}
    }

    assert_equal expected, actual
  end

  test "call without parameters" do
    actual1 = GQL.parse('call').as_json[:root][:call]
    actual2 = GQL.parse('call()').as_json[:root][:call]
    actual3 = GQL.parse('c.call').as_json[:root][:call][:call]
    actual4 = GQL.parse('c.call()').as_json[:root][:call][:call]
    actual5 = GQL.parse('{ f.call }').as_json[:root][:fields][0][:call]
    actual6 = GQL.parse('{ f.call() }').as_json[:root][:fields][0][:call]

    expected = { id: :call, arguments: [], call: nil, fields: nil }

    assert_equal expected, actual1
    assert_equal expected, actual2
    assert_equal expected, actual3
    assert_equal expected, actual4
    assert_equal expected, actual5
    assert_equal expected, actual6
  end

  test "call with numeric parameter" do
    actual1 = GQL.parse('call(123)').as_json[:root][:call]
    actual2 = GQL.parse('c.call(123)').as_json[:root][:call][:call]
    actual3 = GQL.parse('{ f.call(123) }').as_json[:root][:fields][0][:call]

    expected = { id: :call, arguments: [123], call: nil, fields: nil }

    assert_equal expected, actual1
    assert_equal expected, actual2
    assert_equal expected, actual3
  end

  test "call with string parameter" do
    actual1 = GQL.parse('call("123")').as_json[:root][:call]
    actual2 = GQL.parse('c.call("123")').as_json[:root][:call][:call]
    actual3 = GQL.parse('{ f.call("123") }').as_json[:root][:fields][0][:call]

    expected = { id: :call, arguments: ['123'], call: nil, fields: nil }

    assert_equal expected, actual1
    assert_equal expected, actual2
    assert_equal expected, actual3
  end

  test "call with null parameter" do
    actual1 = GQL.parse('call(null)').as_json[:root][:call]
    actual2 = GQL.parse('c.call(null)').as_json[:root][:call][:call]
    actual3 = GQL.parse('{ f.call(null) }').as_json[:root][:fields][0][:call]

    expected = { id: :call, arguments: [nil], call: nil, fields: nil }

    assert_equal expected, actual1
    assert_equal expected, actual2
    assert_equal expected, actual3
  end

  test "call with true parameter" do
    actual1 = GQL.parse('call(true)').as_json[:root][:call]
    actual2 = GQL.parse('c.call(true)').as_json[:root][:call][:call]
    actual3 = GQL.parse('{ f.call(true) }').as_json[:root][:fields][0][:call]

    expected = { id: :call, arguments: [true], call: nil, fields: nil }

    assert_equal expected, actual1
    assert_equal expected, actual2
    assert_equal expected, actual3
  end

  test "call with false parameter" do
    actual1 = GQL.parse('call(false)').as_json[:root][:call]
    actual2 = GQL.parse('c.call(false)').as_json[:root][:call][:call]
    actual3 = GQL.parse('{ f.call(false) }').as_json[:root][:fields][0][:call]

    expected = { id: :call, arguments: [false], call: nil, fields: nil }

    assert_equal expected, actual1
    assert_equal expected, actual2
    assert_equal expected, actual3
  end

  test "call with variable parameter" do
    actual1 = GQL.parse('call(<x>)').as_json[:root][:call]
    actual2 = GQL.parse('c.call(<x>)').as_json[:root][:call][:call]
    actual3 = GQL.parse('{ f.call(<x>) }').as_json[:root][:fields][0][:call]

    expected = { id: :call, arguments: [:x], call: nil, fields: nil }

    assert_equal expected, actual1
    assert_equal expected, actual2
    assert_equal expected, actual3
  end

  test "call with json object parameter" do
    json = '{ "a": 1, "b": [2, { "c": 3 }, true], "d": { "e": false } }'
    arg = JSON.parse(json)

    actual1 = GQL.parse("call(#{json})").as_json[:root][:call]
    actual2 = GQL.parse("c.call(#{json})").as_json[:root][:call][:call]
    actual3 = GQL.parse("{ f.call(#{json}) }").as_json[:root][:fields][0][:call]

    expected = { id: :call, arguments: [arg], call: nil, fields: nil }

    assert_equal expected, actual1
    assert_equal expected, actual2
    assert_equal expected, actual3
  end

  test "call with json array parameter" do
    json = '["a", 1, 3.1, [2, { "b": false, "c": [null, "foo"] }, true], { "d": "e" }]'
    arg = JSON.parse(json)

    actual1 = GQL.parse("call(#{json})").as_json[:root][:call]
    actual2 = GQL.parse("c.call(#{json})").as_json[:root][:call][:call]
    actual3 = GQL.parse("{ f.call(#{json}) }").as_json[:root][:fields][0][:call]

    expected = { id: :call, arguments: [arg], call: nil, fields: nil }

    assert_equal expected, actual1
    assert_equal expected, actual2
    assert_equal expected, actual3
  end

  test "call with mixed parameters" do
    json1 = '{ "a": 1, "b": [2, { "c": 3 }, true], "d": { "e": false } }'
    arg1 = JSON.parse(json1)

    json2 = '["a", 1, 3.1, [2, { "b": false, "c": [null, "foo"] }, true], { "d": "e" }]'
    arg2 = JSON.parse(json2)

    args = "1, 2.3, true, false, null, <x>, #{json1}, #{json2}"

    actual1 = GQL.parse("call(#{args})").as_json[:root][:call]
    actual2 = GQL.parse("c.call(#{args})").as_json[:root][:call][:call]
    actual3 = GQL.parse("{ f.call(#{args}) }").as_json[:root][:fields][0][:call]

    expected = { id: :call, arguments: [1, 2.3, true, false, nil, :x, arg1, arg2], call: nil, fields: nil }

    assert_equal expected, actual1
    assert_equal expected, actual2
    assert_equal expected, actual3
  end

  test "call without subfields" do
    actual1 = GQL.parse('call').as_json[:root][:call][:fields]
    actual2 = GQL.parse('call {}').as_json[:root][:call][:fields]
    actual3 = GQL.parse('c.call').as_json[:root][:call][:call][:fields]
    actual4 = GQL.parse('c.call {}').as_json[:root][:call][:call][:fields]
    actual5 = GQL.parse('{ f.call }').as_json[:root][:fields][0][:call][:fields]
    actual6 = GQL.parse('{ f.call {} }').as_json[:root][:fields][0][:call][:fields]

    assert_nil actual1
    assert_nil actual2
    assert_nil actual3
    assert_nil actual4
    assert_nil actual5
    assert_nil actual6
  end

  test "call with subfields" do
    actual1 = GQL.parse('call { a, b, c }').as_json[:root][:call][:fields].size
    actual2 = GQL.parse('c.call { a, b, c }').as_json[:root][:call][:call][:fields].size
    actual3 = GQL.parse('{ f.call { a, b, c } }').as_json[:root][:fields][0][:call][:fields].size

    assert_equal 3, actual1
    assert_equal 3, actual2
    assert_equal 3, actual3
  end

  test "single root field" do
    actual = GQL.parse('{ field }').as_json

    expected = {
      root: {
        id: '[root]', alias_id: nil,
        call: nil,
        fields: [{ id: :field, alias_id: nil, call: nil, fields: nil }],
      },
      variables: {}
    }

    assert_equal expected, actual
  end

  test "multiple root fields" do
    actual = GQL.parse('{ one, two }').as_json

    expected = {
      root: {
        id: '[root]', alias_id: nil,
        call: nil,
        fields: [
          { id: :one, alias_id: nil, call: nil, fields: nil },
          { id: :two, alias_id: nil, call: nil, fields: nil }
        ],
      },
      variables: {}
    }

    assert_equal expected, actual
  end

  test "root call and variables" do
    actual1 = GQL.parse('<x> = 1 <y> = "foo" call').as_json
    actual2 = GQL.parse('<x> = 1 call <y> = "foo"').as_json
    actual3 = GQL.parse('call <x> = 1 <y> = "foo"').as_json

    expected = {
      root: {
        id: '[root]', alias_id: nil,
        call: { id: :call, arguments: [], call: nil, fields: nil },
        fields: nil,
      },
      variables: { :x => 1, :y => 'foo' }
    }

    assert_equal expected, actual1
    assert_equal expected, actual2
    assert_equal expected, actual3
  end

  test "root field and variables" do
    actual1 = GQL.parse('<x> = 1 <y> = "foo" { field }').as_json
    actual2 = GQL.parse('<x> = 1 { field } <y> = "foo"').as_json
    actual3 = GQL.parse('{ field } <x> = 1 <y> = "foo"').as_json

    expected = {
      root: {
        id: '[root]', alias_id: nil,
        call: nil,
        fields: [{ id: :field, alias_id: nil, call: nil, fields: nil }],
      },
      variables: { :x => 1, :y => 'foo' }
    }

    assert_equal expected, actual1
    assert_equal expected, actual2
    assert_equal expected, actual3
  end

  test "variable types" do
    arr = '["a", 1, 3.1, [2, { "b": false, "c": [null, "foo"] }, true], { "d": "e" }]'
    obj = '{ "a": 1, "b": [2, { "c": 3 }, true], "d": { "e": false } }'

    actual = GQL.parse(<<-QUERY_STRING).as_json[:variables]
      root_call
      <a> = 1
      <b> = 2.3
      <c> = true
      <d> = false
      <e> = null
      <f> = "foo"
      <g> = #{arr}
      <h> = #{obj}
    QUERY_STRING

    expected = {
      a: 1, b: 2.3, c: true, d: false, e: nil, f: 'foo',
      g: JSON.parse(arr), h: JSON.parse(obj)
    }

    assert_equal expected, actual
  end

  test "variables override" do
    actual1 = GQL.parse('<x> = 1 <y> = "foo" <x> = 2 call').as_json
    actual2 = GQL.parse('<x> = 1 <x> = 2 <y> = "foo" call').as_json
    actual3 = GQL.parse('<x> = 1 call <x> = 2 <y> = "foo"').as_json
    actual4 = GQL.parse('call <x> = 1 <x> = 2 <y> = "foo"').as_json

    expected = {
      root: {
        id: '[root]', alias_id: nil,
        call: { id: :call, arguments: [], call: nil, fields: nil },
        fields: nil,
      },
      variables: { :x => 2, :y => 'foo' }
    }

    assert_equal expected, actual1
    assert_equal expected, actual2
    assert_equal expected, actual3
    assert_equal expected, actual4
  end

  test "simple field with alias id" do
    actual = GQL.parse('{ field1 as foo, field2 }').as_json

    expected = {
      root: {
        id: '[root]', alias_id: nil,
        call: nil,
        fields: [
          { id: :field1, alias_id: :foo, call: nil, fields: nil },
          { id: :field2, alias_id: nil, call: nil, fields: nil }
        ],
      },
      variables: {}
    }

    assert_equal expected, actual
  end

  test "field with call (no args) and alias id" do
    actual1 = GQL.parse('{ field1.call as foo, field2 }').as_json
    actual2 = GQL.parse('{ field1.call() as foo, field2 }').as_json

    expected = {
      root: {
        id: '[root]', alias_id: nil,
        call: nil,
        fields: [
          { id: :field1, alias_id: :foo, fields: nil, call: {
              id: :call, arguments: [], call: nil, fields: nil
            } },
          { id: :field2, alias_id: nil, call: nil, fields: nil }
        ],
      },
      variables: {}
    }

    assert_equal expected, actual1
    assert_equal expected, actual2
  end

  test "field with call (args) and alias id" do
    actual = GQL.parse('{ field1.call(1,2) as foo, field2 }').as_json

    expected = {
      root: {
        id: '[root]', alias_id: nil,
        call: nil,
        fields: [
          { id: :field1, alias_id: :foo, fields: nil, call: {
              id: :call, arguments: [1, 2], call: nil, fields: nil
            } },
          { id: :field2, alias_id: nil, call: nil, fields: nil }
        ],
      },
      variables: {}
    }

    assert_equal expected, actual
  end

  test "field with subfields and alias id" do
    actual = GQL.parse('{ field1 { sub1, sub2 } as foo, field2 }').as_json

    expected = {
      root: {
        id: '[root]', alias_id: nil,
        call: nil,
        fields: [
          { id: :field1, alias_id: :foo, call: nil, fields: [
              { id: :sub1, alias_id: nil, call: nil, fields: nil },
              { id: :sub2, alias_id: nil, call: nil, fields: nil }
            ] },
          { id: :field2, alias_id: nil, call: nil, fields: nil }
        ],
      },
      variables: {}
    }

    assert_equal expected, actual
  end

  test "field with call (no args) and subfields and alias id" do
    actual1 = GQL.parse('{ field1.call { sub1, sub2 } as foo, field2 }').as_json
    actual2 = GQL.parse('{ field1.call() { sub1, sub2 } as foo, field2 }').as_json

    expected = {
      root: {
        id: '[root]', alias_id: nil,
        call: nil,
        fields: [
          { id: :field1, alias_id: :foo, fields: nil, call: {
              id: :call, arguments: [], call: nil, fields: [
                { id: :sub1, alias_id: nil, call: nil, fields: nil },
                { id: :sub2, alias_id: nil, call: nil, fields: nil }
              ]
            } },
          { id: :field2, alias_id: nil, call: nil, fields: nil }
        ],
      },
      variables: {}
    }

    assert_equal expected, actual1
    assert_equal expected, actual2
  end

  test "field with call (args) and subfields and alias id" do
    actual = GQL.parse('{ field1.call(1,2) { sub1, sub2 } as foo, field2 }').as_json

    expected = {
      root: {
        id: '[root]', alias_id: nil,
        call: nil,
        fields: [
          { id: :field1, alias_id: :foo, fields: nil, call: {
              id: :call, arguments: [1, 2], call: nil, fields: [
                { id: :sub1, alias_id: nil, call: nil, fields: nil },
                { id: :sub2, alias_id: nil, call: nil, fields: nil }
              ]
            } },
          { id: :field2, alias_id: nil, call: nil, fields: nil }
        ],
      },
      variables: {}
    }

    assert_equal expected, actual
  end

  test "real world example" do
    actual = GQL.parse(<<-QUERY_STRING).as_json
      user(<token>) {
        id,
        is_admin,
        full_name as name,
        created_at { year, month } as created_year_and_month,
        created_at.format("long") as created,
        account {
          bank_name,
          iban,
          saldo as saldo_string,
          saldo {
            currency,
            cents   /* silly block comment */
          }
        },
        albums.first(2) {
          count,
          edges {
            cursor,
            node {
              artist,
              title,
              songs.first(2) {
                edges {
                  id,
                  title.upcase as upcased_title,
                  title.upcase.length as upcased_title_length
                }
              }
            }
          }
        }
      }

      <token> = "ma"  // a variable
    QUERY_STRING

    expected = {
      root: {
        id: '[root]', alias_id: nil,
        call: {
          id: :user,
          arguments: [:token],
          call: nil,
          fields: [
            {
              id: :id,
              alias_id: nil,
              call: nil,
              fields: nil
            }, {
              id: :is_admin,
              alias_id: nil,
              call: nil,
              fields: nil
            }, {
              id: :full_name,
              alias_id: :name,
              call: nil,
              fields: nil
            }, {
              id: :created_at,
              alias_id: :created_year_and_month,
              call: nil,
              fields: [
                {
                  id: :year,
                  alias_id: nil,
                  call: nil,
                  fields: nil
                }, {
                  id: :month,
                  alias_id: nil,
                  call: nil,
                  fields: nil
                }
              ]
            }, {
              id: :created_at,
              alias_id: :created,
              call: {
                id: :format,
                arguments: ["long"],
                call: nil,
                fields: nil
              },
              fields: nil
            }, {
              id: :account,
              alias_id: nil,
              call: nil,
              fields: [
                {
                  id: :bank_name,
                  alias_id: nil,
                  call: nil,
                  fields: nil
                }, {
                  id: :iban,
                  alias_id: nil,
                  call: nil,
                  fields: nil
                }, {
                  id: :saldo,
                  alias_id: :saldo_string,
                  call: nil,
                  fields: nil
                }, {
                  id: :saldo,
                  alias_id: nil,
                  call: nil,
                  fields: [
                    {
                      id: :currency,
                      alias_id: nil,
                      call: nil,
                      fields: nil
                    }, {
                      id: :cents,
                      alias_id: nil,
                      call: nil,
                      fields: nil
                    }
                  ]
                }
              ]
            }, {
              id: :albums,
              alias_id: nil,
              call: {
                id: :first,
                arguments: [2],
                call: nil,
                fields: [
                  {
                    id: :count,
                    alias_id: nil,
                    call: nil,
                    fields: nil
                  }, {
                    id: :edges,
                    alias_id: nil,
                    call: nil,
                    fields: [
                      {
                        id: :cursor,
                        alias_id: nil,
                        call: nil,
                        fields: nil
                      }, {
                        id: :node,
                        alias_id: nil,
                        call: nil,
                        fields: [
                          {
                            id: :artist,
                            alias_id: nil,
                            call: nil,
                            fields: nil
                          }, {
                            id: :title,
                            alias_id: nil,
                            call: nil,
                            fields: nil
                          }, {
                            id: :songs,
                            alias_id: nil,
                            call: {
                              id: :first,
                              arguments: [2],
                              call: nil,
                              fields: [
                                {
                                  id: :edges,
                                  alias_id: nil,
                                  call: nil,
                                  fields: [
                                    {
                                      id: :id,
                                      alias_id: nil,
                                      call: nil,
                                      fields: nil
                                    }, {
                                      id: :title,
                                      alias_id: :upcased_title,
                                      call: {
                                        id: :upcase,
                                        arguments: [],
                                        call: nil,
                                        fields: nil
                                      },
                                      fields: nil
                                    }, {
                                      id: :title,
                                      alias_id: :upcased_title_length,
                                      call: {
                                        id: :upcase,
                                        arguments: [],
                                        call: {
                                          id: :length,
                                          arguments: [],
                                          call: nil,
                                          fields: nil
                                        },
                                        fields: nil
                                      },
                                      fields: nil
                                    }
                                  ]
                                }
                              ]
                            },
                            fields: nil
                          }
                        ]
                      }
                    ]
                  }
                ]
              },
              fields: nil
            }
          ]
        },
        fields: nil
      },
      variables: {
        token: 'ma'
      }
    }

    assert_equal expected, actual
  end
end
