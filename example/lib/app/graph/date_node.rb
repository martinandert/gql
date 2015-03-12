module App
  module Graph
    class DateNode < GQL::Node
      call :format, returns: GQL::String do |format = 'default'|
        I18n.localize target, format: format.to_sym
      end

      number :year
      number :month
      number :day

      def scalar_value
        target.to_s :db
      end
    end
  end
end
