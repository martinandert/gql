require 'cases/helper'

class ArrayItemClass < GQL::String
  string :upcased, -> { target.upcase }
end

class MyFixnum < GQL::Number
  string :whoami, -> { 'I am a number.' }
end

class MyString < GQL::String
  string :whoami, -> { 'I am a string.' }
end

class NodeWithArrays < GQL::Node
  array :single_item_class, -> { %w(a b) }, item_class: ArrayItemClass
  array :multiple_item_classes, -> { ['foo', 42] }, item_class: { Fixnum => MyFixnum, String => MyString }
end

class ArrayTest < GQL::TestCase
  setup do
    @old_root, GQL.root_node_class = GQL.root_node_class, NodeWithArrays
  end

  teardown do
    GQL.root_node_class = @old_root
  end

  test "returns array value" do
    value = GQL.execute('{ single_item_class }')
    assert_equal ['a', 'b'], value[:single_item_class]

    value = GQL.execute('{ multiple_item_classes }')
    assert_equal ['foo', 42], value[:multiple_item_classes]
  end

  test "respects simple item class" do
    value = GQL.execute('{ single_item_class { upcased } }')

    assert_equal [{ upcased: 'A' }, { upcased: 'B' }], value[:single_item_class]
  end

  test "respects item class for each tyoe" do
    value = GQL.execute('{ multiple_item_classes { whoami } }')

    assert_equal [{ whoami: 'I am a string.' }, { whoami: 'I am a number.' }], value[:multiple_item_classes]
  end
end
