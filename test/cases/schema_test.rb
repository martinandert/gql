require 'cases/helper'

class FieldForSchemaCall < GQL::Call
  def execute(a, *b, &c)
  end
end

class AstField < Struct.new(:id, :alias_id, :call, :fields)
end

class AstCall < Struct.new(:id, :arguments, :call, :fields)
end

class ClassWithProc < Struct.new(:proc)
  def parameters
    proc.parameters
  end
end

class SchemaTest < ActiveSupport::TestCase
  test "call class parameters" do
    ast_field = AstField.new(nil, nil, nil, [
      AstField.new(:parameters, nil, nil, [
        AstField.new(:id, nil, nil, nil),
        AstField.new(:type, nil, nil, nil)
      ])
    ])

    schema_call = GQL::Schema::Call.new(ast_field, FieldForSchemaCall, {}, {})

    expected = [{ id: 'a', type: 'required' }, { id: 'b', type: 'rest' }, { id: 'c', type: 'block' }]

    assert_equal expected, schema_call.value[:parameters]
  end

  test "call proc parameters" do
    ast_field = AstField.new(nil, nil, nil, [
      AstField.new(:parameters, nil, nil, [
        AstField.new(:id, nil, nil, nil),
        AstField.new(:type, nil, nil, nil)
      ])
    ])

    schema_call = GQL::Schema::Call.new(ast_field, ClassWithProc.new(-> (a, *b, &c) { }), {}, {})

    expected = [{ id: 'a', type: 'required' }, { id: 'b', type: 'rest' }, { id: 'c', type: 'block' }]

    assert_equal expected, schema_call.value[:parameters]
  end

  test "schema parameter has a scalar value" do
    ast_field = AstField.new(nil, nil, nil, [
      AstField.new(:parameters, nil, nil, nil)
    ])

    schema_call = GQL::Schema::Call.new(ast_field, ClassWithProc.new(-> (a, *b, &c) { }), {}, {})

    assert_instance_of Array, schema_call.value[:parameters]
    assert_not_empty schema_call.value[:parameters].compact
  end

  test "schema field has a scalar value" do
    ast_field = AstField.new(nil, nil, nil, nil)

    field = GQL::Schema::Field.new(ast_field, GQL::Field, {}, {})

    assert_equal 'GQL::Field', field.value
  end

  test "schema call has a scalar value" do
    ast_field = AstField.new(nil, nil, nil, nil)

    call = GQL::Schema::Call.new(ast_field, GQL::Field, {}, {})

    assert_equal 'GQL::Field', call.value
  end

  test "list.find raises if id is not found" do
    ast_call = AstCall.new(:find, ['foo'], nil, nil)

    ast_field = AstField.new(nil, nil, ast_call, nil)

    list = GQL::Schema::List.new(ast_field, [], {}, {})

    assert_raises GQL::Error, /id not found: foo/ do
      list.value
    end
  end

  test "call_list.find returns correct schema call" do
    ast_call = AstCall.new(:find, ['bar'], nil, [
      AstField.new(:id, nil, nil, nil),
      AstField.new(:parameters, nil, nil, nil)
    ])

    ast_field = AstField.new(nil, nil, ast_call, nil)

    foo = Class.new(GQL::Call).tap do |call_class|
      call_class.id = 'foo'
      call_class.proc = -> x {}
    end

    bar = Class.new(GQL::Call).tap do |call_class|
      call_class.id = 'bar'
      call_class.proc = -> a, *b {}
    end

    list = GQL::Schema::List.new(ast_field, [foo, bar], {}, {})

    assert_equal({ id: 'bar', parameters: ['a (required)', 'b (rest)'] }, list.value)
  end

  test "field_list.find returns correct schema field" do
    ast_call = AstCall.new(:find, ['bar'], nil, [
      AstField.new(:id, nil, nil, nil),
      AstField.new(:fields, nil, nil, [
        AstField.new(:count, nil, nil, nil),
      ])
    ])

    ast_field = AstField.new(nil, nil, ast_call, nil)

    foo = Class.new(GQL::Field).tap do |field_class|
      field_class.id = 'foo'
      field_class.number :number
    end

    bar = Class.new(GQL::Field).tap do |field_class|
      field_class.id = 'bar'
      field_class.string :string
      field_class.number :number
    end

    list = GQL::Schema::List.new(ast_field, [foo, bar], {}, {})

    assert_equal({ id: 'bar', fields: { count: GQL.debug ? 3 : 2 } }, list.value)
  end
end


