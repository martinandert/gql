require 'cases/helper'

class ErrorsTest < ActiveSupport::TestCase
  test "errors expose json representation" do
    begin
      prev, GQL.debug = GQL.debug, false

      actual    = GQL::Error.new('foo').as_json
      expected  = { error: { code: 100, type: 'error' } }
      assert_equal expected, actual

      actual    = GQL::Error.new('foo', 123).as_json
      expected  = { error: { code: 123, type: 'error' } }
      assert_equal expected, actual

      actual    = GQL::Error.new('foo', 123, 'bar').as_json
      expected  = { error: { code: 123, type: 'error', handle: 'bar' } }
      assert_equal expected, actual

      GQL.debug = true

      actual    = GQL::Error.new('foo').as_json
      expected  = { error: { code: 100, type: 'error', message: 'foo' } }
      assert_equal expected, actual

      actual    = GQL::Error.new('foo', 123).as_json
      expected  = { error: { code: 123, type: 'error', message: 'foo' } }
      assert_equal expected, actual

      actual    = GQL::Error.new('foo', 123, 'bar').as_json
      expected  = { error: { code: 123, type: 'error', handle: 'bar', message: 'foo' } }
      assert_equal expected, actual
    ensure
      GQL.debug = prev
    end
  end
end
