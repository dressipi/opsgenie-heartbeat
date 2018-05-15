require 'spec_helper'
require 'logger'


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
      expect(Opsgenie::Heartbeat).to receive(:create).with(name:'dressipi', description:'test', interval:10, unit:'minutes', enabled: true, team: nil)
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

  describe 'self.update' do
    it 'updates the heartbeat with specified parameters' do
      stub = stub_request(:patch, "https://api.opsgenie.com/v2/heartbeats")
      .with(body:{ name:'dressipi', ownerTeam: {name: 'someteam'}}, headers: {'Authorization': "GenieKey #{Opsgenie::Heartbeat.configuration.api_key}", "Content-Type": "application/json"})
      .and_return(status: 200, body: "", headers:{})

      Opsgenie::Heartbeat.update(name:'dressipi', team: {name: 'someteam'})
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

  describe 'handling exceptions' do
    context 'when raise_error is set to true' do
      before do
        Opsgenie::Heartbeat.configure do |c|
          c.raise_error = true
        end
      end
      it 'raises an exception' do
        stub_request(:delete, "https://api.opsgenie.com/v2/heartbeats/dressipi")
        .with(headers: {'Authorization': "GenieKey #{Opsgenie::Heartbeat.configuration.api_key}", "Content-Type": "application/json"})
        .to_raise(StandardError)
        expect do
          Opsgenie::Heartbeat.delete('dressipi')
        end.to raise_error(StandardError)
      end
    end

    context 'when raise_error is set to false' do
      before do
        Opsgenie::Heartbeat.configure do |c|
          c.raise_error = false
        end
      end
      it 'does not raise an exception' do
        stub_request(:delete, "https://api.opsgenie.com/v2/heartbeats/dressipi")
        .with(headers: {'Authorization': "GenieKey #{Opsgenie::Heartbeat.configuration.api_key}", "Content-Type": "application/json"})

        expect do
          Opsgenie::Heartbeat.delete('dressipi')
        end.not_to raise_error
      end
    end

    context 'when logger is not nil' do
      let(:e) {Exception.new}
      let(:logger) {
        Opsgenie::Heartbeat.configure do |c|
          c.logger = Logger.new(STDOUT)
        end
      }
      it 'prints message in log file' do
        expect(logger).to receive(:info).with("Exception raised during heartbeat: #{e.message} #{e.backtrace}")
        Opsgenie::Heartbeat.resolve_exception(e)
      end
    end
  end

  describe 'name_transformer' do
    before(:example) do
      Opsgenie::Heartbeat.configure do |c|
        c.name_transformer = -> (name) {"#{name}-test_name"}
      end
    end

    it 'transforms the right name' do
      stub = stub_request(:delete, "https://api.opsgenie.com/v2/heartbeats/dressipi-test_name")
      .with(headers: {'Authorization': "GenieKey #{Opsgenie::Heartbeat.configuration.api_key}", "Content-Type": "application/json"})
      .and_return(status: 200, body: "", headers:{})

      Opsgenie::Heartbeat.delete('dressipi')
      expect(stub).to have_been_made
    end
  end
end
