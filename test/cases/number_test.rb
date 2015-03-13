require 'cases/helper'

class FieldWithNumber < GQL::Field
  number :number, -> { 42 }
end

class NumberTest < ActiveSupport::TestCase
  setup do
    @old_root, GQL.root_field_class = GQL.root_field_class, FieldWithNumber
  end

  teardown do
    GQL.root_field_class = @old_root
  end

  test "returns number value" do
    value = GQL.execute('{ number }')

    assert_equal 42, value[:number]
  end

  test "has is_zero call" do
    value = GQL.execute('{ number.is_zero as is_number_zero }')

    assert_equal false, value[:is_number_zero]
  end
end
