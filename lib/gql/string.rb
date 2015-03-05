module GQL
  module Fields
    class String < Field
      call :upcase, -> { target.upcase }
      call :downcase, -> { target.downcase }
      call :length, Integer, -> { target.size }

      # These are just example calls, monkeypatch to add your own.
    end
  end
end
