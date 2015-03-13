require 'active_support/core_ext/string/inflections'
require 'active_support/per_thread_registry'

module GQL
  class Registry
    extend ActiveSupport::PerThreadRegistry

    attr_reader :cache

    def initialize
      reset
    end

    def reset
      @cache = {}
    end

    def fetch(key, baseclass = Field)
      cache[key] || begin
        raise Errors::FieldClassNotSet.new(baseclass, 'TODO') if key.nil?

        const, name =
          if key.instance_of? ::Class
            [key, key.name]
          else
            [key.constantize, key]
          end

        raise Errors::InvalidFieldClass.new(const, baseclass) unless const <= baseclass

        cache.update name => const, const => const

        cache[key]
      end
    end

    alias_method :[], :fetch
  end
end
