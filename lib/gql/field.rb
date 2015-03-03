module GQL
  class Field < Node
    def __raw_value
      __target
    end
  end
end
