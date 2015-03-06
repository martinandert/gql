require 'active_support/core_ext/class/attribute'

module GQL
  class Field < Node
    class_attribute :id, :method, instance_writer: false, instance_predicate: false

    class << self
      def build_class(id, method, options = {})
        Class.new(self).tap do |field_class|
          field_class.id = id.to_s
          field_class.method = method
        end
      end
    end
  end
end
