require 'cases/helper'

class ItemObject < Struct.new(:foo)
end

class ConnectionListClass < GQL::Field
  number :count
end

class ConnectionItemClass < GQL::Field
  string :foo
end

class FieldWithConnections < GQL::Field
  ITEMS = [ItemObject.new('bar'), ItemObject.new('baz')]

  connection :default_list_class, -> { FieldWithConnections::ITEMS }, item_class: ConnectionItemClass
  connection :custom_list_class,  -> { FieldWithConnections::ITEMS }, item_class: ConnectionItemClass, list_class: ConnectionListClass
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
end
