require 'cases/helper'

class FieldWithIdCursor < GQL::Number
  cursor :to_s
end

class FieldWithProcCursor < GQL::Number
  cursor -> { target * 2 }
end

class FieldRootField < GQL::Field
  object :id_cursor,   -> { target }, object_class: FieldWithIdCursor
  object :proc_cursor, -> { target }, object_class: FieldWithProcCursor

  string :no_calls, -> { 'foo' }

  string :some_field do
    (target * 3).to_s
  end
end

class HasRemoveFieldTest < GQL::Field
  string :present
end

class HasRemoveCallTest < GQL::Field
  call :present
end

class FieldTest < ActiveSupport::TestCase
  setup do
    @old_root, GQL.root_class = GQL.root_class, FieldRootField
    @old_proc, GQL.root_target_proc = GQL.root_target_proc, -> _ { 42 }
  end

  teardown do
    GQL.root_target_proc = @old_proc
    GQL.root_class = @old_root
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
    assert_equal false, GQL::Field.respond_to?(:foo)
    GQL.field_types[:foo] = Object
    assert_equal true, GQL::Field.respond_to?(:foo)
    GQL.field_types.delete :foo
  end

  test "undefined field type raises error" do
    assert_raises GQL::Errors::NoMethodError do
      Class.new(GQL::Field).class_eval do
        undefined_field_type :foo
      end
    end
  end

  test "undefined field type has correct cause set" do
    begin
      Class.new(GQL::Field).class_eval do
        undefined_field_type :foo
      end
    rescue GQL::Errors::NoMethodError => exc
      assert_instance_of NoMethodError, exc.cause
    end
  end

  test "in debug mode each field exposes a __type__ subfield" do
    begin
      prev, GQL.debug = GQL.debug, false

      assert_raises GQL::Errors::FieldNotFound, /__type__/ do
        GQL.execute '{ __type__ }'
      end

      assert_raises GQL::Errors::FieldNotFound, /__type__/ do
        GQL.execute '{ some_field { __type__ } }'
      end

      GQL.debug = true

      assert_equal 'FieldRootField', GQL.execute('{ __type__ }')[:__type__]
      assert_equal 'FieldRootField', GQL.execute('{ __type__ { name } }')[:__type__][:name]
    ensure
      GQL.debug = prev
    end
  end

  test "has field and remove field" do
    assert HasRemoveFieldTest.has_field?(:present)
    assert HasRemoveFieldTest.const_defined?(:PresentField)

    assert_not HasRemoveFieldTest.has_field?(:not_present)

    HasRemoveFieldTest.remove_field :present

    assert_not HasRemoveFieldTest.has_field?(:present)
    assert_not HasRemoveFieldTest.const_defined?(:PresentField)
  end

  test "has call and remove call" do
    assert HasRemoveCallTest.has_call?(:present)
    assert HasRemoveCallTest.const_defined?(:PresentCall)

    assert_not HasRemoveCallTest.has_call?(:not_present)

    HasRemoveCallTest.remove_call :present

    assert_not HasRemoveCallTest.has_call?(:present)
    assert_not HasRemoveCallTest.const_defined?(:PresentCall)
  end
end
