require 'active_support/concern'
require 'active_support/core_ext/array/extract_options'
require 'active_support/core_ext/class/attribute'
require 'active_support/core_ext/class/subclasses'
require 'active_support/core_ext/object/try'
require 'active_support/core_ext/string/inflections'

module GQL
  module Mixins
    module HasCalls
      extend ActiveSupport::Concern

      included do
        class_attribute :calls, :call_proc, instance_accessor: false, instance_predicate: false
        self.calls = {}
      end

      module ClassMethods
        def add_call(id, *args, &block)
          remove_call id

          id            = id.to_sym
          options       = args.extract_options!
          call_spec     = args.shift || block || proc_for_call(id)
          result_spec   = options[:returns] || call_spec.try(:result_class)
          result_class  = result_class_from_spec(result_spec)

          build_call_class(call_spec, id, result_class).tap do |call_class|
            propagate :call, id, call_class
          end
        end

        alias :call :add_call

        def remove_call(id)
          shutdown :call, id.to_sym
        end

        def has_call?(id)
          calls.has_key? id.to_sym
        end

        private
          def build_call_class(spec, id, result_class)
            call_class_from_spec(spec).tap do |call_class|
              call_class.id = id
              call_class.result_class = result_class

              if result_class && result_class.name.nil?
                call_class.const_set :Result, result_class
              end
            end
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

          def const_name_for_call(id)
            :"#{id.to_s.camelize}Call"
          end

          def proc_for_call(id)
            instance_exec id, &(call_proc || GQL.default_call_proc)
          end

          def result_class_from_spec(spec)
            result_class =
              case spec
              when ::Array
                result_class_from_connection_spec spec.dup
              when ::Hash
                result_class_from_mapping_spec spec.dup
              else
                spec
              end

            result_class && Registry.fetch(result_class)
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

          def result_class_from_mapping_spec(spec)
            Object.build_class :result, nil, class: spec
          end
      end

      private
        def value_of_call(ast_call)
          call_class = call_class_for_id(ast_call.id)
          call_class.execute(self.class, ast_call, target, variables, context)
        end

        def call_class_for_id(id)
          self.class.calls[id] or raise Errors::CallNotFound.new(id, self.class)
        end
    end
  end
end
