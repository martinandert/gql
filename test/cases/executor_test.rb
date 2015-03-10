require 'cases/helper'

class ExecutorTest < GQL::TestCase
  setup do
    @old_root, GQL.root_node_class = GQL.root_node_class, nil
  end

  teardown do
    GQL.root_node_class = @old_root
  end

  test "raises when root node class is not set" do
    ast_query = Struct.new(:root, :variables).new(nil, nil)

    assert_raises GQL::Errors::RootClassNotSet do
      GQL.execute 'foo'
    end
  end
end
