require 'cases/helper'

class ItemObject < Struct.new(:foo)
end

class ConnectionListClass < GQL::Field
  number :count
end

class ConnectionItemClass < GQL::Field
  string :foo
end

class ItemClassA < Struct.new(:foo)
end

class ItemClassB < Struct.new(:bar)
end

class ConnItemClassA < GQL::Field
  string :foo
end

class ConnItemClassB < GQL::Field
  string :foo, -> { target.bar }
end

class FieldWithConnections < GQL::Field
  ITEMS = [ItemObject.new('bar'), ItemObject.new('baz')]
  MAP_ITEMS = [ItemClassA.new('a'), ItemClassB.new('b')]
  MAPPING = { ItemClassA => ConnItemClassA, ItemClassB => ConnItemClassB }
  STRING_MAPPING = { ItemClassA => 'ConnItemClassA', ItemClassB => 'ConnItemClassB' }

  connection :default_list_class, -> { ITEMS }, item_class: ConnectionItemClass
  connection :custom_list_class,  -> { ITEMS }, item_class: ConnectionItemClass, list_class: ConnectionListClass
  connection :list_class_mapped,  -> { MAP_ITEMS }, item_class: MAPPING

  connection :string_item_class, -> { ITEMS }, item_class: 'ConnectionItemClass'
  connection :string_list_class,  -> { ITEMS }, item_class: ConnectionItemClass, list_class: 'ConnectionListClass'
  connection :string_list_class_mapped,  -> { MAP_ITEMS }, item_class: STRING_MAPPING
end

class ConnectionTest < ActiveSupport::TestCase
  setup do
    @old_root, GQL.root_class = GQL.root_class, FieldWithConnections
  end

  teardown do
    GQL.root_class = @old_root
  end

  test "edges field returns nils if accessed without subfields" do
    value = GQL.execute('{ default_list_class { edges } }')

    assert_equal [nil, nil], value[:default_list_class][:edges]
  end

  test "edges field returns values if accessed with subfields" do
    value = GQL.execute('{ default_list_class { edges { foo } } }')

    assert_equal [{ foo: 'bar' }, { foo: 'baz' }], value[:default_list_class][:edges]
  end

  test "respects custom list class" do
    value = GQL.execute('{ custom_list_class { count, edges { foo } } }')

    assert_equal 2, value[:custom_list_class][:count]
    assert_equal [{ foo: 'bar' }, { foo: 'baz' }], value[:custom_list_class][:edges]
  end

  test "with model-to-field mapping as item class" do
    value = GQL.execute('{ list_class_mapped { edges { foo } } }')

    assert_equal [{ foo: 'a' }, { foo: 'b' }], value[:list_class_mapped][:edges]
  end

  test "works with string item class" do
    GQL::Registry.reset

    assert FieldWithConnections.fields[:string_item_class] < GQL::Lazy
    value = GQL.execute('{ string_item_class { edges { foo } } }')
    assert_equal [{ foo: 'bar' }, { foo: 'baz' }], value[:string_item_class][:edges]

    GQL::Registry.reset

    assert FieldWithConnections.fields[:string_list_class] < GQL::Lazy
    value = GQL.execute('{ string_list_class { count } }')
    assert_equal 2, value[:string_list_class][:count]

    GQL::Registry.reset

    assert FieldWithConnections.fields[:string_list_class_mapped] < GQL::Lazy
    value = GQL.execute('{ string_list_class_mapped { edges { foo } } }')
    assert_equal [{ foo: 'a' }, { foo: 'b' }], value[:string_list_class_mapped][:edges]
  end
end
