require 'codeclimate-test-reporter'
CodeClimate::TestReporter.start

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'gql'

require 'active_support'
require 'active_support/testing/autorun'
require 'minitest/perf' if ENV['PERF']

ActiveSupport::TestCase.test_order = :random
