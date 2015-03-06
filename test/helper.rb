$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'gql'
require 'example'

require 'active_support'
require 'active_support/testing/autorun'

ActiveSupport::TestCase.test_order = :random
