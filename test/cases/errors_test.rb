require 'cases/helper'

class ErrorsTest < GQL::TestCase
  test "errors expose json representation" do
    prev, ENV['DEBUG'] = ENV['DEBUG'], nil

    actual    = GQL::Error.new('foo').as_json
    expected  = { error: { code: 100, type: 'error' } }
    assert_equal expected, actual

    actual    = GQL::Error.new('foo', 123).as_json
    expected  = { error: { code: 123, type: 'error' } }
    assert_equal expected, actual

    actual    = GQL::Error.new('foo', 123, 'bar').as_json
    expected  = { error: { code: 123, type: 'error', handle: 'bar' } }
    assert_equal expected, actual

    ENV['DEBUG'] = '1'

    actual    = GQL::Error.new('foo').as_json
    expected  = { error: { code: 100, type: 'error', message: 'foo' } }
    assert_equal expected, actual

    actual    = GQL::Error.new('foo', 123).as_json
    expected  = { error: { code: 123, type: 'error', message: 'foo' } }
    assert_equal expected, actual

    actual    = GQL::Error.new('foo', 123, 'bar').as_json
    expected  = { error: { code: 123, type: 'error', handle: 'bar', message: 'foo' } }
    assert_equal expected, actual

    ENV['DEBUG'] = prev
  end
end