require 'cases/helper'

class MyObject < Struct.new(:foo)
end

class ObjectFieldClass < GQL::Field
  call :upcase_foo, -> { target.foo.upcase!; target }
  string :foo
end

class AClass < Struct.new(:a)
end

class BClass < Struct.new(:b)
end

class AClassField < GQL::Field
  string :a
end

class BClassField < GQL::Field
  string :b
end

class FieldWithObject < GQL::Field
  object :class_as_object_class,  -> { MyObject.new('bar') }, object_class: ObjectFieldClass
  object :string_as_object_class, -> { MyObject.new('bar') }, object_class: 'ObjectFieldClass'

  object :hash_with_class_values_as_object_class,  -> { BClass.new('b') }, object_class: { AClass => AClassField, BClass => BClassField }
  object :hash_with_string_values_as_object_class, -> { AClass.new('a') }, object_class: { AClass => 'AClassField', BClass => 'BClassField' }

  object :proc_returning_class_as_object_class,  -> { AClass.new('a') }, object_class: -> target, context { target.is_a?(AClass) ? AClassField : 'BClassField' }
  object :proc_returning_string_as_object_class, -> { BClass.new('b') }, object_class: -> target          { target.is_a?(AClass) ? AClassField : 'BClassField' }
end

class ObjectTest < ActiveSupport::TestCase
  setup do
    @old_root, GQL.root_class = GQL.root_class, FieldWithObject
  end

  teardown do
    GQL.root_class = @old_root
  end

  test "returns nil without fields" do
    value = GQL.execute('{ class_as_object_class as obj }')

    assert_nil value[:obj]
  end

  test "returns its fields" do
    value = GQL.execute('{ class_as_object_class as obj { foo } }')

    assert_equal 'bar', value[:obj][:foo]
  end

  test "respects call" do
    value = GQL.execute('{ class_as_object_class.upcase_foo { foo } as obj }')

    assert_equal 'BAR', value[:obj][:foo]
  end

  test "string provided as object class" do
    GQL::Registry.reset

    assert FieldWithObject.fields[:string_as_object_class] < GQL::Lazy
    value = GQL.execute('{ string_as_object_class as obj { foo } }')
    assert_equal 'bar', value[:obj][:foo]
  end

  test "hash with class values provided as object_class" do
    value = GQL.execute('{ hash_with_class_values_as_object_class as obj { b } }')
    assert_equal 'b', value[:obj][:b]
  end

  test "hash with string values provided as object_class" do
    GQL::Registry.reset

    value = GQL.execute('{ hash_with_string_values_as_object_class as obj { a } }')
    assert_equal 'a', value[:obj][:a]
  end

  test "proc returning class provided as object_class" do
    value = GQL.execute('{ proc_returning_class_as_object_class as obj { a } }')
    assert_equal 'a', value[:obj][:a]
  end

  test "proc returning string provided as object_class" do
    value = GQL.execute('{ proc_returning_string_as_object_class as obj { b } }')
    assert_equal 'b', value[:obj][:b]
  end
end
