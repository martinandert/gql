require 'cases/helper'

class MyGQLNode < GQL::Node
end

class GQLTest < GQL::TestCase
  test "exposes its VERSION constant" do
    refute_nil GQL::VERSION
  end

  test "can set the configuration object" do
    begin
      GQL.config = self
      assert_equal self, GQL.config
      assert_equal self, Thread.current[:gql_config]
    ensure
      GQL.config = GQL::Config.new
    end
  end

  test "has no root node class set by default" do
    assert_nil GQL.root_node_class
  end

  test "can set the root node class to a valid class" do
    begin
      prev = GQL.root_node_class

      assert_nothing_raised { GQL.root_node_class = MyGQLNode }
      assert_equal MyGQLNode, GQL.root_node_class
    ensure
      GQL.root_node_class = prev
    end
  end

  test "raises an GQL::Errors::InvalidNodeClass exception when setting an invalid root class" do
    assert_raises GQL::Errors::InvalidNodeClass do
      GQL.root_node_class = Array
    end
  end

  test "has a root target proc set by default" do
    assert_instance_of Proc, GQL.root_target_proc
  end

  test "can set the root target proc" do
    begin
      prev = GQL.root_target_proc
      proc = -> { }

      assert_nothing_raised { GQL.root_target_proc = proc }
      assert_equal proc, GQL.root_target_proc
    ensure
      GQL.root_target_proc = prev
    end
  end

  test "has basic field types set by default" do
    assert_instance_of Hash, GQL.field_types
    assert_not_empty GQL.field_types
  end

  test "can set the field types" do
    begin
      prev = GQL.field_types
      hash = { foo: 'bar' }

      assert_nothing_raised { GQL.field_types = hash }
      assert_equal hash, GQL.field_types
    ensure
      GQL.field_types = prev
    end
  end

  test "uses GQL::Node as the default list class" do
    assert_equal GQL::Node, GQL.default_list_class
  end

  test "can set the default list class to a valid class" do
    begin
      prev = GQL.root_node_class

      assert_nothing_raised { GQL.default_list_class = MyGQLNode }
      assert_equal MyGQLNode, GQL.default_list_class
    ensure
      GQL.default_list_class = prev
    end
  end

  test "raises an GQL::Errors::InvalidNodeClass exception when setting an invalid list class" do
    assert_raises GQL::Errors::InvalidNodeClass do
      GQL.default_list_class = Array
    end
  end

  test "has a default field proc set by default" do
    assert_instance_of Proc, GQL.default_field_proc
  end

  test "can set the default field proc" do
    begin
      prev = GQL.default_field_proc
      proc = -> { }

      assert_nothing_raised { GQL.default_field_proc = proc }
      assert_equal proc, GQL.default_field_proc
    ensure
      GQL.default_field_proc = prev
    end
  end

  test "has a default call proc set by default" do
    assert_instance_of Proc, GQL.default_call_proc
  end

  test "can set the default call proc" do
    begin
      prev = GQL.default_call_proc
      proc = -> { }

      assert_nothing_raised { GQL.default_call_proc = proc }
      assert_equal proc, GQL.default_call_proc
    ensure
      GQL.default_call_proc = prev
    end
  end
end
