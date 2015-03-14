require 'cases/helper'

class RegistryCall < GQL::Call
end

class RegistryTest < ActiveSupport::TestCase
  test "cache returns a Hash" do
    assert_instance_of Hash, GQL::Registry.cache
  end

  test "reset clears the cache" do
    GQL::Registry.fetch('GQL::String')
    assert_not_empty GQL::Registry.cache
    GQL::Registry.reset
    assert_empty GQL::Registry.cache
  end

  test "fetch inserts missing names into the cache" do
    GQL::Registry.reset
    assert_equal GQL::Number, GQL::Registry.fetch('GQL::Number')
    assert_equal 2, GQL::Registry.cache.keys.size
    assert_equal GQL::Number, GQL::Registry.cache['GQL::Number']
    assert_equal GQL::Number, GQL::Registry.cache[GQL::Number]
  end

  test "fetch raises if key is not resolved to a GQL::Field" do
    ['Fixnum', Fixnum].each do |key|
      GQL::Registry.reset

      assert_raises GQL::Errors::InvalidClass, /#{key} must be a \(subclass of\) GQL::Field/ do
        GQL::Registry.fetch key
      end
    end
  end

  test "fetch accepts an optional base class as second argument" do
    ['Fixnum', Fixnum].each do |key|
      GQL::Registry.reset

      assert_raises GQL::Errors::InvalidClass, /#{key} must be a \(subclass of\) GQL::Call/ do
        GQL::Registry.fetch key, GQL::Call
      end
    end

    ['RegistryCall', RegistryCall].each do |key|
      GQL::Registry.reset

      assert_nothing_raised do
        GQL::Registry.fetch key, GQL::Call
      end
    end
  end
end
