module GQL
  class Config
    def root
      @@root ||= nil
    end

    def root=(value)
      @@root = value
    end

    def field_types
      @@field_types ||= {}
    end

    def field_types=(value)
      @@field_types = value
    end
  end
end
