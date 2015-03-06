require 'active_support/core_ext/class/attribute'
require 'active_support/core_ext/string/inflections'

module GQL
  class Field < Node
    class_attribute :calls, instance_writer: false, instance_predicate: false
    self.calls = {}

    class << self
      def call(id, result_class = nil, target_method = nil)
        if target_method.nil? && result_class.is_a?(Proc)
          target_method = result_class
          result_class  = nil
        end

        target_method ||= -> (*args) { target.public_send(id, *args) }

        options = { result_class: result_class, target_method: target_method }

        call_class = Call.build_class(id, options)

        self.const_set "#{id.to_s.camelize}Call", call_class
        self.calls = calls.merge(id.to_sym => call_class)
      end
    end
  end
end
