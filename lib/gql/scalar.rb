module GQL
  class Scalar < Field
    def scalar_value
      target
    end
  end
end
