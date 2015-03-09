require 'cases/helper'

class NodeWithIdCursor < GQL::Number
  cursor :to_s
end

class NodeWithProcCursor < GQL::Number
  cursor -> { target * 2 }
end

class NodeRootNode < GQL::Node
  object :id_cursor,   -> { 42 }, node_class: NodeWithIdCursor
  object :proc_cursor, -> { 42 }, node_class: NodeWithProcCursor

  string :no_calls, -> { 'foo' }
end

class NodeTest < GQL::TestCase
  setup do
    @old_root, GQL.root_node_class = GQL.root_node_class, NodeRootNode
  end

  teardown do
    GQL.root_node_class = @old_root
  end

  test "cursor with id" do
    assert_equal '42', GQL.execute('{ id_cursor { cursor } }')[:id_cursor][:cursor]
  end

  test "cursor with proc" do
    assert_equal 84, GQL.execute('{ proc_cursor { cursor } }')[:proc_cursor][:cursor]
  end

  test "accessing undefined field" do
    assert_raises GQL::Errors::UndefinedField do
      GQL.execute '{ missing }'
    end
  end

  test "accessing undefined call" do
    assert_raises GQL::Errors::UndefinedCall do
      GQL.execute '{ no_calls.missing("foo") }'
    end
  end
end
