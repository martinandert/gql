module GQL
  class Simple < Field
    def raw_value
      target
    end
  end
end
