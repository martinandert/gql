require 'cases/helper'

class VersionTest < ActiveSupport::TestCase
  test "exposes its VERSION constant" do
    refute_nil GQL::VERSION
  end
end
