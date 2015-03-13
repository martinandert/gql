require 'active_support/concern'
require 'active_support/core_ext/string/inflections'

module GQL
  module Mixins
    module Common
      def propagate(type, id, klass)
        const_name = send("const_name_for_#{type}", id)
        accessor   = type.to_s.pluralize

        const_set const_name, klass

        [self, *descendants].each do |c|
          c.send "#{accessor}=", c.send(accessor).merge(id => klass)
        end
      end

      def shutdown(type, id)
        const_name = send("const_name_for_#{type}", id)
        accessor   = type.to_s.pluralize

        [self, *descendants].each do |c|
          next unless c.send("has_#{type}?", id)

          c.send :remove_const, const_name if c.const_defined?(const_name, false)
          c.send(accessor).delete id
        end
      end
    end
  end
end
