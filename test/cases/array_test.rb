require 'cases/helper'

class ArrayItemClass < GQL::String
  string :upcased, -> { target.upcase }
end

class NodeWithArray < GQL::Node
  array :array, -> { %w(a b) }, item_class: ArrayItemClass
end

class ArrayTest < GQL::TestCase
  setup do
    @old_root, GQL.root_node_class = GQL.root_node_class, NodeWithArray
  end

  teardown do
    GQL.root_node_class = @old_root
  end

  test "returns array value" do
    value = GQL.execute('{ array }')

    assert_equal ['a', 'b'], value[:array]
  end

  test "respects item class" do
    value = GQL.execute('{ array { upcased } }')

    assert_equal [{ upcased: 'A' }, { upcased: 'B' }], value[:array]
  end
end
