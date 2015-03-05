module GQL
  module Schema
    class List < GQL::Connection
      number :count

      call :reverse
      call :first, -> size { target.first(size) }
    end
  end
end
