require "opsgenie/heartbeat/version"
require 'net/https'
require 'uri'
require 'json'

module Opsgenie
  module Heartbeat
    class << self
      attr_reader :region, :enabled, :api_key
    end

    def self.regionalize_name(name)
      if region == 'eu-west-1'
        name
      else
        "#{name}-#{region}"
      end
    end

    def self.pulse(name)
      return unless enabled
      name = regionalize_name name
      begin
        uri = URI.parse("https://api.opsgenie.com/v2/heartbeats/#{name}/ping")
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        data = {name: name}
        http.post(uri.path, data.to_json, {'Authorization': "GenieKey #{api_key}", "Content-Type": "application/json"})
      rescue => e
        Rails.logger.info("Exception raised during heartbeat: #{e.message} #{e.backtrace}")
      end
    end

    def self.ensure(name:, interval:, unit: , description:, enabled: true)
      return unless enabled
      original_name = name
      name = regionalize_name name

      uri = URI.parse("https://api.opsgenie.com/v2/heartbeats/#{name}")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      response = http.get(uri.path)
      unless response.is_a?(Net::HTTPSuccess)
        create(name: original_name, description: description, interval: interval, unit: unit, enabled: enabled)
      end
    end

    def self.create(name:,description:,interval:,unit:, enabled:)
      name = regionalize_name name

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
        http.post(uri.path, doc.to_json, {'Authorization': "GenieKey #{api_key}", "Content-Type": "application/json"})
      rescue => e
        Rails.logger.info("Exception raised during heartbeat: #{e.message} #{e.backtrace}")
      end
    end

    def self.delete(name)
      return unless enabled
      name = regionalize_name name

      begin
        uri = URI.parse("https://api.opsgenie.com/v2/heartbeats/#{name}")
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true

        http.delete(uri.path, {'Authorization': "GenieKey #{api_key}", "Content-Type": "application/json"})
      rescue => e
        Rails.logger.info("Exception raised during heartbeat: #{e.message} #{e.backtrace}")
      end
    end
  end
end
