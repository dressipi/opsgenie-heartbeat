require "bundler/setup"
require 'webmock/rspec'
require 'byebug'
require "opsgenie/heartbeat/heartbeat"
require "opsgenie/heartbeat/config"

Opsgenie::Heartbeat.configure do |c|
  c.enabled = true
  c.api_key = '123456'
end

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
