module App
  module Graph
    class DurationField < GQL::Number
      call :human, returns: GQL::String do
        if target <= 0
          "0:00"
        else
          min = target / 60
          sec = target - min * 60

          "#{min}:#{sec.to_s.rjust(2, '0')}"
        end
      end
    end
  end
end
