require 'active_support/concern'
require 'active_support/core_ext/array/extract_options'
require 'active_support/core_ext/class/attribute'
require 'active_support/core_ext/string/inflections'
require 'active_support/core_ext/object/try'

module GQL
  module HasCalls
    extend ActiveSupport::Concern

    included do
      class_attribute :calls, :call_proc, instance_accessor: false, instance_predicate: false
      self.calls = {}
    end

    module ClassMethods
      def call(id, *args)
        options = args.extract_options!

        call_spec = args.shift || proc_for_call(id)
        result_spec = options[:returns] || call_spec.try(:result_class)
        result_class = result_class_from_spec(result_spec)

        Node.validate_is_subclass! result_class, 'result' if result_class

        call_class = call_class_from_spec(call_spec)
        call_class.id = id.to_s
        call_class.result_class = result_class

        self.const_set "#{id.to_s.camelize}Call", call_class
        self.calls = calls.merge(id.to_sym => call_class)
      end

      private
        def proc_for_call(id)
          instance_exec id, &(call_proc || GQL.default_call_proc)
        end

        def result_class_from_spec(spec)
          return spec unless spec.is_a? ::Array

          result_class_from_connection_spec spec.dup
        end

        def result_class_from_connection_spec(spec)
          if spec.size == 1
            spec.unshift GQL.default_list_class
          end

          options = {
            list_class: spec.first,
            item_class: spec.last
          }

          Connection.build_class :result, nil, options
        end

        def call_class_from_spec(spec)
          return Class.new(spec) unless spec.is_a?(Proc)

          Class.new(Call).tap do |call_class|
            call_class.class_eval do
              self.proc = spec

              def execute(*args)
                instance_exec(*args, &self.class.proc)
              end
            end
          end
        end
    end
  end
end
