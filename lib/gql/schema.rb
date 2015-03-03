require 'singleton'
require 'forwardable'

module GQL
  class Schema
    include Singleton

    class << self
      extend Forwardable

      delegate [:root, :root=, :fields] => :instance
    end

    attr_accessor :root
    attr_reader :fields

    def initialize
      @fields = {}
    end
  end
end
