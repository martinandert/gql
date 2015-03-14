require 'cases/helper'

class FieldWithLazies < GQL::Field
  PROC = -> { 'yo! '}

  field :string_type, PROC, type: 'GQL::Array', bar: 'baz', item_class: GQL::String

  not_yet_defined_field_type :foo, -> { 'foo' }
end

class FooFieldType < GQL::String
end

class LazyTest < ActiveSupport::TestCase
  setup do
    @old_root, GQL.root_class = GQL.root_class, FieldWithLazies
    @old_field_types = GQL.field_types.dup
  end

  teardown do
    GQL.field_types = @old_field_types
    GQL.root_class = @old_root
  end

  test "field with string type" do
    lazy_field_class = FieldWithLazies.fields[:string_type]

    assert lazy_field_class < GQL::Lazy
    assert_equal FieldWithLazies, lazy_field_class.owner
    assert_equal :string_type, lazy_field_class.id
    assert_equal({ bar: 'baz', item_class: GQL::String }, lazy_field_class.options)
    assert_equal FieldWithLazies::PROC, lazy_field_class.proc
    assert_equal 'GQL::Array', lazy_field_class.type

    lazy_field_class.spur.tap do |spurred_field_class|
      assert_equal spurred_field_class, FieldWithLazies.fields[:string_type]
      assert spurred_field_class < GQL::Array
      assert_equal :string_type, spurred_field_class.id
      assert_equal FieldWithLazies::PROC, spurred_field_class.proc
      assert_equal GQL::String, spurred_field_class.item_class[:any]
    end
  end

  test "not yet defined field type" do
    assert_raises GQL::Errors::UnknownFieldType, /not_yet_defined_field_type.*?FieldWithLazies/ do
      GQL.execute '{ foo }'
    end

    GQL.field_types[:not_yet_defined_field_type] = FooFieldType

    value = assert_nothing_raised do
      GQL.execute '{ foo }'
    end

    assert_equal({ foo: 'foo' }, value)
  end
end
