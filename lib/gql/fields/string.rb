module GQL
  module Fields
    class String < Field
      call :upcase do
        target.upcase
      end

      call :downcase do
        target.downcase
      end

      call :length, returns: Integer do
        target.size
      end

      # These are just example calls, monkeypatch to add your own.
    end
  end
end
