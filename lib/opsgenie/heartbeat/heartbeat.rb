require "opsgenie/heartbeat/config"
require 'net/https'
require 'uri'
require 'json'
require 'rack'

module Opsgenie
  module Heartbeat

    def self.pulse(name)
      return unless configuration.enabled
      name = configuration.name_transformer.call(name)
      begin
        uri = URI.parse("https://api.opsgenie.com/v2/heartbeats/#{Rack::Utils.escape name}/ping")
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        data = {name: name}
        http.post(uri.path, data.to_json, {'Authorization': "GenieKey #{configuration.api_key}", "Content-Type": "application/json"})
      rescue => e
        resolve_exception e
      end
    end

    def self.ensure(name:, interval:, unit: , description:, enabled: true)
      return unless configuration.enabled
      original_name = name
      name =  configuration.name_transformer.call(name)

      uri = URI.parse("https://api.opsgenie.com/v2/heartbeats/#{Rack::Utils.escape name}")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      response = http.get(uri.path)
      unless response.is_a?(Net::HTTPSuccess)
        create(name: original_name, description: description, interval: interval, unit: unit, enabled: enabled)
      end
    end

    def self.create(name:,description:,interval:,unit:, enabled:)
      name = configuration.name_transformer.call(name)

      begin
        uri = URI.parse('https://api.opsgenie.com/v2/heartbeats')
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        doc = {
          name: name,
          description: description,
          interval: interval,
          intervalUnit: unit,
          enabled: enabled
        }
        http.post(uri.path, doc.to_json, {'Authorization': "GenieKey #{configuration.api_key}", "Content-Type": "application/json"})
      rescue => e
        resolve_exception e
      end
    end

    def self.delete(name)
      return unless configuration.enabled
      name = configuration.name_transformer.call(name)

      begin
        uri = URI.parse("https://api.opsgenie.com/v2/heartbeats/#{Rack::Utils.escape name}")
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true

        http.delete(uri.path, {'Authorization': "GenieKey #{configuration.api_key}", "Content-Type": "application/json"})
      rescue => e
        resolve_exception e
      end
    end

    def self.resolve_exception e
      if configuration.logger
        configuration.exception[:logger].info("Exception raised during heartbeat: #{e.message} #{e.backtrace}")
      elsif configuration.raise_error
        raise "Exception raised during heartbeat: #{e.message} #{e.backtrace}"
      end
    end
  end
end
