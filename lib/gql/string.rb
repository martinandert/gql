module GQL
  class String < Simple
    # These are just example calls. Monkeypatch class to add your own.
    call :upcase, -> { target.upcase }
    call :downcase, -> { target.downcase }
    call :length, Number, -> { target.size }
  end
end
