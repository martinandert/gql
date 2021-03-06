module GQL
  module Schema
    class Parameter < GQL::Field
      TYPES = {
        req:      'required',
        opt:      'optional',
        rest:     'rest',
        keyreq:   'required keyword',
        key:      'optional keyword',
        keyrest:  'keyword rest',
        block:    'block'
      }.freeze

      cursor -> { target[1].to_s }

      string :id,   -> { target[1].to_s }
      string :type, -> { TYPES[target[0]] || target[0].to_s }

      def scalar_value
        "#{target[1]} (#{TYPES[target[0]] || target[0]})"
      end
    end
  end
end
