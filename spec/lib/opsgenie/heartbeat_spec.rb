require 'spec_helper'

describe Opsgenie::Heartbeat do
  describe 'self.pulse' do
    it 'pings heartbeat request' do
      stub = stub_request(:post, "https://api.opsgenie.com/v2/heartbeats/dressipi/ping")
      .with(body:{ name: "dressipi"}, headers: {'Authorization': "GenieKey 123456", "Content-Type": "application/json"})
      .and_return(status: 200, body: "", headers:{})

      Opsgenie::Heartbeat.pulse('dressipi')
      expect(stub).to have_been_made
    end
  end

  describe 'self.ensure' do
    it 'does nothing if the heartbeat already exists' do
      stub = stub_request(:get, "https://api.opsgenie.com/v2/heartbeats/dressipi")
      .and_return(status: 200)
      expect(Opsgenie::Heartbeat).not_to receive(:create)
      Opsgenie::Heartbeat.ensure(name:'dressipi', interval:10, unit:'minutes', description:'test')
      expect(stub).to have_been_requested
    end

    it 'calls create when response is not success' do
      stub = stub_request(:get, "https://api.opsgenie.com/v2/heartbeats/dressipi")
      .and_return(status: 500)
      expect(Opsgenie::Heartbeat).to receive(:create).with(name:'dressipi', description:'test', interval:10, unit:'minutes', enabled: true)
      Opsgenie::Heartbeat.ensure(name:'dressipi', interval:10, unit:'minutes', description:'test', enabled: true)
      expect(stub).to have_been_requested
    end
  end

  describe 'self.create' do
    it 'creates heartbeat request' do
      stub = stub_request(:post, "https://api.opsgenie.com/v2/heartbeats")
      .with(body:{ name:'dressipi', description:'test', interval:10, intervalUnit:'minutes', enabled: true}, headers: {'Authorization': "GenieKey #{Opsgenie::Heartbeat.configuration.api_key}", "Content-Type": "application/json"})
      .and_return(status: 200, body: "", headers:{})

      Opsgenie::Heartbeat.create(name:'dressipi', description:'test', interval:10, unit:'minutes', enabled: true)
      expect(stub).to have_been_made
    end
  end

  describe 'self.delete' do
    it 'deletes heartbeat' do
      stub = stub_request(:delete, "https://api.opsgenie.com/v2/heartbeats/dressipi")
      .with(headers: {'Authorization': "GenieKey #{Opsgenie::Heartbeat.configuration.api_key}", "Content-Type": "application/json"})
      .and_return(status: 200, body: "", headers:{})

      Opsgenie::Heartbeat.delete('dressipi')
      expect(stub).to have_been_made
    end
  end

  describe 'logger' do
    it 'raises an exception' do
      stub = stub_request(:delete, "https://api.opsgenie.com/v2/heartbeats/dressipi")
      .with(headers: {'Authorization': "GenieKey #{Opsgenie::Heartbeat.configuration.api_key}", "Content-Type": "application/json"})
      .to_raise(StandardError)
      expect do
        Opsgenie::Heartbeat.delete('dressipi')
      end.to raise_error(StandardError)
      Opsgenie::Heartbeat.delete('dressipi')
    end
  end

  describe 'name_transformer' do
    before(:example) do
      Opsgenie::Heartbeat.configure do |c|
        c.enabled = true
        c.api_key = '123456'
        c.region = 'test_region_name'
        c.name_transformer = lambda do |name|
          if c.region == 'eu-west-1'
            name
          else
            "#{name}-#{c.region}"
          end
        end
        c.logger = nil
      end
    end
    it 'transforms the right name' do
      stub = stub_request(:delete, "https://api.opsgenie.com/v2/heartbeats/dressipi-test_region_name")
      .with(headers: {'Authorization': "GenieKey #{Opsgenie::Heartbeat.configuration.api_key}", "Content-Type": "application/json"})
      .and_return(status: 200, body: "", headers:{})

      Opsgenie::Heartbeat.delete('dressipi')
      expect(stub).to have_been_made
    end
  end
end
