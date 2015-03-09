require 'cases/helper'

class NodeWithString < GQL::Node
  string :string, -> { 'fOoBaR' }
end

class StringTest < GQL::TestCase
  setup do
    @old_root, GQL.root_node_class = GQL.root_node_class, NodeWithString
  end

  teardown do
    GQL.root_node_class = @old_root
  end

  test "returns string value" do
    value = GQL.execute('{ string }')

    assert_equal 'fOoBaR', value[:string]
  end

  test "has upcase call" do
    value = GQL.execute('{ string.upcase }')

    assert_equal 'FOOBAR', value[:string]
  end

  test "has downcase call" do
    value = GQL.execute('{ string.downcase }')

    assert_equal 'foobar', value[:string]
  end

  test "has length call" do
    value = GQL.execute('{ string.length as string_length }')

    assert_equal 6, value[:string_length]
  end
end
