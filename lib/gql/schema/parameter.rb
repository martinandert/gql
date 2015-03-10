module GQL
  module Schema
    class Parameter < GQL::Node
      MODES = {
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
      string :mode, -> { GQL::Schema::Parameter::MODES[target[0]] || target[0].to_s }
    end
  end
end
