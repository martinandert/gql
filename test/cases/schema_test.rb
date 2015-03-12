require 'cases/helper'

class NodeForSchemaCall < GQL::Call
  def execute(a, *b, &c)
  end
end

class AstField < Struct.new(:id, :alias_id, :call, :fields)
end

class ClassWithProc < Struct.new(:proc)
end

class SchemaTest < GQL::TestCase
  test "call class parameters" do
    ast_node = AstField.new(nil, nil, nil, [
      AstField.new(:parameters, nil, nil, [
        AstField.new(:id, nil, nil, nil),
        AstField.new(:type, nil, nil, nil)
      ])
    ])

    schema_call = GQL::Schema::Call.new(ast_node, NodeForSchemaCall, {}, {})

    expected = [{ id: 'a', type: 'required' }, { id: 'b', type: 'rest' }, { id: 'c', type: 'block' }]

    assert_equal expected, schema_call.value[:parameters]
  end

  test "call proc parameters" do
    ast_node = AstField.new(nil, nil, nil, [
      AstField.new(:parameters, nil, nil, [
        AstField.new(:id, nil, nil, nil),
        AstField.new(:type, nil, nil, nil)
      ])
    ])

    schema_call = GQL::Schema::Call.new(ast_node, ClassWithProc.new(-> (a, *b, &c) { }), {}, {})

    expected = [{ id: 'a', type: 'required' }, { id: 'b', type: 'rest' }, { id: 'c', type: 'block' }]

    assert_equal expected, schema_call.value[:parameters]
  end

  test "parameter node has a raw value" do
    ast_node = AstField.new(nil, nil, nil, [
      AstField.new(:parameters, nil, nil, nil)
    ])

    schema_call = GQL::Schema::Call.new(ast_node, ClassWithProc.new(-> (a, *b, &c) { }), {}, {})

    assert_instance_of Array, schema_call.value[:parameters]
    assert_not_empty schema_call.value[:parameters].compact
  end

  test "root node has a raw value" do
    ast_node = AstField.new(nil, nil, nil, nil)

    root = GQL::Schema::Root.new(ast_node, GQL::Node, {}, {})

    assert_equal 'GQL::Node', root.value
  end

  test "field node has a raw value" do
    ast_node = AstField.new(nil, nil, nil, nil)

    field = GQL::Schema::Field.new(ast_node, GQL::Node, {}, {})

    assert_equal 'GQL::Node', field.value
  end

  test "call node has a raw value" do
    ast_node = AstField.new(nil, nil, nil, nil)

    call = GQL::Schema::Call.new(ast_node, GQL::Node, {}, {})

    assert_equal 'GQL::Node', call.value
  end
end


