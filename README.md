# Opsgenie::Heartbeat

Use OpsGenie Heartbeat version 2 (REST API) https://docs.opsgenie.com/docs/rest-api/heartbeat-api

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'opsgenie-heartbeat'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install opsgenie-heartbeat

## Usage

Ping, create or delete heartbeat requests with personalized name of heartbeat.

  *Ping is used to ping defined heartbeat in OpsGenie.* <br />
  *Ensure is used to define heartbeats in OpsGenie.* <br />
  *Delete is used to delete monitored heartbeat in OpsGenie.*<br />


In yours initializers folder, define new file with:
```ruby
  require "opsgenie/heartbeat"

  Opsgenie::Heartbeat.configure do |config|
    #define opsgenie_api key in secrets.yml
    config.api_key = Rails.application.secrets.opsgenie_api
    #define environment from which requests should be made
    config.enabled = Rails.env.production?
    #customized method for naming heartbeats, may provide your own method
    config.name_transformer = lambda do |name|
      if Rails.configuration.aws_region == 'eu-west-1'
        name
      else
        "#{name}-#{config.Rails.configuration.aws_region}"
      end
    end
    #handling exceptions:
    # - if logger is provided, error is written there,
    # - if config.raise_error = true is set then it raises error
    # - if nothing is defined, then it ignores error
    config.logger = Rails.logger

    #will set the team to Myteam on all new heartbeats
    #you can override when you create the heartbeat.
    config.default_team = {name: 'Myteam'} # or { id: '8418d193-2alp-4490-b331-8c02cdd196b7'}

    #retry timedout api calls upto the specified number of times, with a random backoff
    #default is no retries
    config.retries = 2
  end
  ```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/dressipi/opsgenie-heartbeat.
