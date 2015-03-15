module GQL
  class Number < Scalar
    # This is just an example call. Monkeypatch class to add your own.
    call :is_zero, -> { target.zero? }, returns: 'GQL::Boolean'
  end
end
