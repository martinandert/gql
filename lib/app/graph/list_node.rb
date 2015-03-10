module App
  module Graph
    class ListNode < GQL::Node
      number :count
      boolean :any, -> { target.any? }

      call :skip, -> size { target.offset(size) }
      call :take, -> size { target.limit(size) }
    end
  end
end
