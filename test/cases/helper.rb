require 'codeclimate-test-reporter'
CodeClimate::TestReporter.start

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'gql'

require 'active_support'
require 'active_support/testing/autorun'
require 'minitest/reporters'

reporter_options = { color: true, slow_count: 3 }
Minitest::Reporters.use! [Minitest::Reporters::DefaultReporter.new(reporter_options)]

ActiveSupport::TestCase.test_order = :random
