require 'cases/helper'

class MyObject < Struct.new(:foo)
end

class ObjectFieldClass < GQL::Field
  call :upcase_foo, -> { target.foo.upcase!; target }
  string :foo
end

class FieldWithObject < GQL::Field
  object :object, -> { MyObject.new('bar') }, field_class: ObjectFieldClass
end

class ObjectTest < GQL::TestCase
  setup do
    @old_root, GQL.root_field_class = GQL.root_field_class, FieldWithObject
  end

  teardown do
    GQL.root_field_class = @old_root
  end

  test "returns nil without fields" do
    value = GQL.execute('{ object }')

    assert_nil value[:object]
  end

  test "returns its fields" do
    value = GQL.execute('{ object { foo } }')

    assert_equal 'bar', value[:object][:foo]
  end

  test "respects call" do
    value = GQL.execute('{ object.upcase_foo { foo } }')

    assert_equal 'BAR', value[:object][:foo]
  end
end
