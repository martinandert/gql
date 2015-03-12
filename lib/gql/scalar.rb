module GQL
  class Scalar < Node
    def scalar_value
      target
    end
  end
end
