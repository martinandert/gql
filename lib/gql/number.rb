module GQL
  class Number < Simple
    # This is just an example call. Monkeypatch class to add your own.
    call :is_zero, Boolean, -> { target.zero? }
  end
end
