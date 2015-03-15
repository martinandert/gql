module GQL
  module Schema
    class List < GQL::Field
      RESULT_PROC = -> target, _ { target.superclass == GQL::Call ? 'GQL::Schema::Call' : 'GQL::Schema::Field' }

      call :count, returns: GQL::Number
      number :count

      call :reverse
      call :first, -> size { target.first(size) }

      call :find, returns: RESULT_PROC do |id|
        item = target.find { |item| item.id.to_s == id.to_s }
        raise(GQL::Error, "id not found: #{id}") unless item
        item.respond_to?(:spur) ? item.spur : item
      end
    end
  end
end
