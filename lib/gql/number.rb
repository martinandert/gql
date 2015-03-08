module GQL
  class Number < Raw
    # This is just an example call. Monkeypatch class to add your own.
    call :is_zero, -> { target.zero? }, returns: Boolean
  end
end
