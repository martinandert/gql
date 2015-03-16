module App
  module Graph
    class YouField < GQL::Field
      self.field_proc = -> id { -> { target[id] } }

      string :ip_address
      number :queries_count
    end
  end
end
