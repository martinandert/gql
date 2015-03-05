module GQL
  module Fields
    class Integer < Field
      # This is just an example call, monkeypatch to add your own.
      call :is_zero, Boolean, -> { target.zero? }
    end
  end
end
