require "opsgenie/heartbeat/config"
require 'net/https'
require 'uri'
require 'json'
require 'rack'

module Opsgenie
  module Heartbeat
    class << self
      def pulse(name)
        return unless configuration.enabled
        name = configuration.name_transformer.call(name)
        begin
          uri = URI.parse("https://api.opsgenie.com/v2/heartbeats/#{Rack::Utils.escape name}/ping")
          http = Net::HTTP.new(uri.host, uri.port)
          http.use_ssl = true
          response = http.get(uri.path, {'Authorization': "GenieKey #{configuration.api_key}"})
          if !response.is_a?(Net::HTTPSuccess)
            configuration.logger.info("Error creating or updating heartbeat: #{response}") if configuration.logger
          end

        rescue => e
          resolve_exception e
        end
      end

      def ensure(name:, interval:, unit: , description:, enabled: true, team: nil)
        return unless configuration.enabled
        original_name = name
        name =  configuration.name_transformer.call(name)

        uri = URI.parse(url_for_resource(:get, name))
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        response = http.get(uri.path, {'Authorization': "GenieKey #{configuration.api_key}"})
        unless response.is_a?(Net::HTTPSuccess)
          create(name: original_name, description: description, interval: interval, unit: unit, enabled: enabled, team: team)
        end
      end

      def delete(name)
        return unless configuration.enabled
        name = configuration.name_transformer.call(name)

        begin
          uri = URI.parse(url_for_resource(:delete, name))
          http = Net::HTTP.new(uri.host, uri.port)
          http.use_ssl = true

          http.delete(uri.path, {'Authorization': "GenieKey #{configuration.api_key}", "Content-Type": "application/json"})
        rescue => e
          resolve_exception e
        end
      end

      def update(name:, interval: nil, unit: nil, description: nil, enabled: nil, team: nil)
        return unless configuration.enabled
        create_or_update(:patch, name: name, description: description, interval: interval, unit: unit, enabled: enabled, team: team)
      end

      def create(name:, interval: nil, unit: nil, description: nil, enabled: nil, team: nil)
        return unless configuration.enabled
        create_or_update(:post, name: name, description: description, interval: interval, unit: unit, enabled: enabled, team: team)
      end


      private

      def url_for_resource(verb, name)
        if verb == :post
          'https://api.opsgenie.com/v2/heartbeats'
        else
          "https://api.opsgenie.com/v2/heartbeats/#{Rack::Utils.escape name}"
        end
      end

      def create_or_update(verb, name:,description:,interval:,unit:, enabled:, team:)
        name = configuration.name_transformer.call(name)

        begin
          uri = URI.parse(url_for_resource(verb, name))
          http = Net::HTTP.new(uri.host, uri.port)
          http.use_ssl = true
          team_to_assign = case team
          when nil then configuration.default_team
          when false then nil
          else
            team
          end
          doc = {
            name: name,
            description: description,
            interval: interval,
            intervalUnit: unit,
            enabled: enabled,
            ownerTeam: team_to_assign
          }.reject {|_, value| value.nil?}
          response = http.public_send(verb, uri.path, doc.to_json, {'Authorization': "GenieKey #{configuration.api_key}", "Content-Type": "application/json"})

          if !response.is_a?(Net::HTTPSuccess)
            configuration.logger.info("Error creating or updating heartbeat: #{response}") if configuration.logger
          end

        rescue => e
          resolve_exception e
        end
      end

      def resolve_exception e
        configuration.logger.info("Exception raised during heartbeat: #{e.message} #{e.backtrace}") if configuration.logger
        raise if configuration.raise_error
      end
    end
  end
end
