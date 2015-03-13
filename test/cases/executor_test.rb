require 'cases/helper'

class ExecutorTest < ActiveSupport::TestCase
  setup do
    @old_root, GQL.root_field_class = GQL.root_field_class, nil
  end

  teardown do
    GQL.root_field_class = @old_root
  end

  test "raises when root field class is not set" do
    ast_query = Struct.new(:root, :variables).new(nil, nil)

    assert_raises GQL::Errors::RootClassNotSet do
      GQL.execute 'foo'
    end
  end
end
