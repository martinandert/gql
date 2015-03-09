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
      prev_root = GQL.root_node_class

      assert_nothing_raised { GQL.root_node_class = MyGQLNode }
      assert_equal MyGQLNode, GQL.root_node_class
    ensure
      GQL.root_node_class = prev_root
    end
  end

  test "raises an GQL::Errors::InvalidNodeClass exception when setting an invalid root class" do
    assert_raises GQL::Errors::InvalidNodeClass do
      GQL.root_node_class = Array
    end
  end

  test "uses GQL::Node as the default list class" do
    assert_equal GQL::Node, GQL.default_list_class
  end

  test "can set the default list class to a valid class" do
    begin
      prev_list = GQL.root_node_class

      assert_nothing_raised { GQL.default_list_class = MyGQLNode }
      assert_equal MyGQLNode, GQL.default_list_class
    ensure
      GQL.default_list_class = prev_list
    end
  end

  test "raises an GQL::Errors::InvalidNodeClass exception when setting an invalid list class" do
    assert_raises GQL::Errors::InvalidNodeClass do
      GQL.default_list_class = Array
    end
  end

  # to be continued...
end
