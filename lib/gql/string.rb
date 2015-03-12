module GQL
  class String < Scalar
    # These are just example calls. Monkeypatch class to add your own.
    call :upcase
    call :downcase
    call :length, returns: Number
  end
end
