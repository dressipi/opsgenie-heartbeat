module Opsgenie
  module Heartbeat
    class<<self
      attr_accessor :configuration
    end
    def self.configure
      self.configuration ||= Config.new
      yield(configuration)
    end

    class Config
      attr_accessor :region, :enabled, :api_key, :name_transformer, :logger
    end
  end
end
