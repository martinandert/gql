require 'cases/helper'

class NodeWithIdCursor < GQL::Number
  cursor :to_s
end

class NodeWithProcCursor < GQL::Number
  cursor -> { target * 2 }
end

class NodeRootNode < GQL::Node
  object :id_cursor,   -> { target }, node_class: NodeWithIdCursor
  object :proc_cursor, -> { target }, node_class: NodeWithProcCursor

  string :no_calls, -> { 'foo' }

  string :some_field do
    (target * 3).to_s
  end
end

class NodeTest < GQL::TestCase
  setup do
    @old_root, GQL.root_node_class = GQL.root_node_class, NodeRootNode
    @old_proc, GQL.root_target_proc = GQL.root_target_proc, -> _ { 42 }
  end

  teardown do
    GQL.root_target_proc = @old_proc
    GQL.root_node_class = @old_root
  end

  test "cursor with id" do
    assert_equal '42', GQL.execute('{ id_cursor { cursor } }')[:id_cursor][:cursor]
  end

  test "cursor with proc" do
    assert_equal 84, GQL.execute('{ proc_cursor { cursor } }')[:proc_cursor][:cursor]
  end

  test "accessing undefined field" do
    assert_raises GQL::Errors::FieldNotFound do
      GQL.execute '{ missing }'
    end
  end

  test "accessing undefined call" do
    assert_raises GQL::Errors::CallNotFound do
      GQL.execute '{ no_calls.missing("foo") }'
    end
  end

  test "node field just delegates to self (for now)" do
    assert_equal '126', GQL.execute('{ node { some_field } }')[:node][:some_field]
  end

  test "respond_to? with field type" do
    assert_nil GQL.field_types[:foo]
    assert_equal false, GQL::Node.respond_to?(:foo)
    GQL.field_types[:foo] = Object
    assert_equal true, GQL::Node.respond_to?(:foo)
    GQL.field_types.delete :foo
  end

  test "validate_is_subclass!" do
    assert_nothing_raised do
      GQL::Node.validate_is_subclass! GQL::Node, 'foo'
      GQL::Node.validate_is_subclass! GQL::String, 'bar'
    end

    assert_raises GQL::Errors::UndefinedNodeClass do
      GQL::Node.validate_is_subclass! nil, 'baz'
    end

    assert_raises GQL::Errors::InvalidNodeClass do
      GQL::Node.validate_is_subclass! Fixnum, 'bam'
    end
  end

  test "undefined field type raises error" do
    assert_raises GQL::Errors::NoMethodError do
      Class.new(GQL::Node).class_eval do
        undefined_field_type :foo
      end
    end
  end

  test "undefined field type has correct cause set" do
    begin
      Class.new(GQL::Node).class_eval do
        undefined_field_type :foo
      end
    rescue GQL::Errors::NoMethodError => exc
      assert_instance_of NoMethodError, exc.cause
    end
  end
end
