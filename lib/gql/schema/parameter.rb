module GQL
  module Schema
    class Parameter < GQL::Node
      cursor { target[1].to_s }

      string :id do
        target[1].to_s
      end

      string :mode do
        case target[0]
        when :req
          'required'
        when :opt
          'optional'
        when :rest
          'rest'
        when :keyreq
          'required keyword'
        when :key
          'optional keyword'
        when :keyrest
          'keyword rest'
        when :block
          'block'
        else
          target[0].to_s
        end
      end
    end
  end
end
