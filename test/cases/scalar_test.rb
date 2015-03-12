require 'cases/helper'

class ScalarTarget < Struct.new(:foo)
  def identity
    self
  end

  def bar(times = 1)
    'bar' * times
  end

  def baz
    'baz'
  end
end

class ExtendedScalar < GQL::Scalar
  call :bar
  string :baz
end

class FieldWithScalar < GQL::Field
  field :identity, type: GQL::Scalar
  field :extended, -> { target }, type: ExtendedScalar
end

class ScalarTest < GQL::TestCase
  setup do
    @old_root, GQL.root_field_class = GQL.root_field_class, FieldWithScalar
    @old_proc, GQL.root_target_proc = GQL.root_target_proc, -> _ { ScalarTarget.new('foo') }
  end

  teardown do
    GQL.root_target_proc = @old_proc
    GQL.root_field_class = @old_root
  end

  test "returns raw value" do
    value = GQL.execute('{ identity }')

    assert_instance_of ScalarTarget, value[:identity]
    assert_equal 'foo', value[:identity].foo
  end

  test "extended returns raw value" do
    value = GQL.execute('{ extended }')

    assert_instance_of ScalarTarget, value[:extended]
    assert_equal 'foo', value[:extended].foo
  end

  test "extended with call" do
    value = GQL.execute('{ extended.bar(2) }')

    assert_equal 'barbar', value[:extended]
  end

  test "extended with field" do
    value = GQL.execute('{ extended { baz } }')

    assert_equal 'baz', value[:extended][:baz]
  end
end
