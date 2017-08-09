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
end
