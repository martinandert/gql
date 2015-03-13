require 'cases/helper'

class FieldForSchemaCall < GQL::Call
  def execute(a, *b, &c)
  end
end

class AstField < Struct.new(:id, :alias_id, :call, :fields)
end

class ClassWithProc < Struct.new(:proc)
end

class SchemaTest < ActiveSupport::TestCase
  test "call class parameters" do
    ast_node = AstField.new(nil, nil, nil, [
      AstField.new(:parameters, nil, nil, [
        AstField.new(:id, nil, nil, nil),
        AstField.new(:type, nil, nil, nil)
      ])
    ])

    schema_call = GQL::Schema::Call.new(ast_node, FieldForSchemaCall, {}, {})

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

  test "schema parameter has a scalar value" do
    ast_node = AstField.new(nil, nil, nil, [
      AstField.new(:parameters, nil, nil, nil)
    ])

    schema_call = GQL::Schema::Call.new(ast_node, ClassWithProc.new(-> (a, *b, &c) { }), {}, {})

    assert_instance_of Array, schema_call.value[:parameters]
    assert_not_empty schema_call.value[:parameters].compact
  end

  test "schema field has a scalar value" do
    ast_node = AstField.new(nil, nil, nil, nil)

    field = GQL::Schema::Field.new(ast_node, GQL::Field, {}, {})

    assert_equal 'GQL::Field', field.value
  end

  test "schema call has a scalar value" do
    ast_node = AstField.new(nil, nil, nil, nil)

    call = GQL::Schema::Call.new(ast_node, GQL::Field, {}, {})

    assert_equal 'GQL::Field', call.value
  end
end


