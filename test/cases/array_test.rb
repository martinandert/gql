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

class FieldWithArrays < GQL::Field
  array :class_as_item_class, -> { %w(a b) }, item_class: ArrayItemClass
  array :string_as_item_class, -> { %w(a b) }, item_class: 'ArrayItemClass'

  array :hash_with_class_values_as_item_class, -> { ['foo', 42] }, item_class: { Fixnum => MyFixnum, String => MyString }
  array :hash_with_string_values_as_item_class, -> { ['foo', 42] }, item_class: { Fixnum => 'MyFixnum', String => 'MyString' }

  array :proc_as_item_class,  -> { ['foo', 42] }, item_class: -> item, _ { item.is_a?(String) ? MyString : 'MyFixnum' }
end

class ArrayTest < ActiveSupport::TestCase
  setup do
    @old_root, GQL.root_class = GQL.root_class, FieldWithArrays
  end

  teardown do
    GQL.root_class = @old_root
  end

  test "returns array value" do
    value = GQL.execute('{ class_as_item_class as arr }')
    assert_equal ['a', 'b'], value[:arr]
  end

  test "class as item_class" do
    value = GQL.execute('{ class_as_item_class as arr { upcased } }')

    assert_equal [{ upcased: 'A' }, { upcased: 'B' }], value[:arr]
  end

  test "string as item_class" do
    GQL::Registry.reset

    assert FieldWithArrays.fields[:string_as_item_class] < GQL::Lazy
    value = GQL.execute('{ string_as_item_class as arr }')
    assert_equal ['a', 'b'], value[:arr]
  end

  test "hash with class values provided as item_class" do
    value = GQL.execute('{ hash_with_class_values_as_item_class as arr { whoami } }')
    assert_equal [{ whoami: 'I am a string.' }, { whoami: 'I am a number.' }], value[:arr]
  end

  test "hash with string values provided as item_class" do
    GQL::Registry.reset

    value = GQL.execute('{ hash_with_string_values_as_item_class as arr { whoami } }')
    assert_equal [{ whoami: 'I am a string.' }, { whoami: 'I am a number.' }], value[:arr]
  end

  test "proc as item_class" do
    GQL::Registry.reset

    value = GQL.execute('{ proc_as_item_class as arr { whoami } }')
    assert_equal [{ whoami: 'I am a string.' }, { whoami: 'I am a number.' }], value[:arr]
  end
end
