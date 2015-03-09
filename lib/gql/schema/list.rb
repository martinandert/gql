module GQL
  module Schema
    class List < GQL::Node
      number :count

      call :reverse
      call :first, -> size { target.first(size) }
    end
  end
end
