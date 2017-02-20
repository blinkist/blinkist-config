# Blinkist::Config

This GEM allows you to access configuration stores with different adapters. Here're some examples of usage:

### Using the ENV
```ruby
# First setup the Config to use the ENV as config store
Blinkist::Config.env = ENV["RAILS_ENV"]
Blinkist::Config.app_name = ENV["APP_NAME"]
Blinkist::Config.adapter_type = :env

my_config_value = Blinkist::Config.get "some/folder/config"

# This is being translated to ENV["SOME_FOLDER_CONFIG"]
```

### Using Diplomat & Consul

If you want to use Consul's key value store, simply use our diplomat adapter.

* [https://www.consul.io/](https://www.consul.io/)
* [https://github.com/WeAreFarmGeek/diplomat](https://github.com/WeAreFarmGeek/diplomat)


```ruby
# First setup the Config to use the ENV as config store
Blinkist::Config.env = ENV["RAILS_ENV"]
Blinkist::Config.app_name = ENV["APP_NAME"]
Blinkist::Config.adapter_type = ENV["CONSUL_AVAILABLE"] == "true" ? :diplomat : :env

my_config_value = Blinkist::Config.get "some/folder/config"

# This is will try to get a value from Consul's KV store at "APP_NAME/some/folder/config"
```

### Using Diplomat with a folder scope
```ruby
# Here we setting a scope outside of the app

my_config_value = Blinkist::Config.get "another/config", scope: "global"

# This is will try to get a value from Consul's KV store at "global/another/config"
```


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'blinkist-config'
```

## Usage

You have to set up the GEM before you can use it. The basic setup requires this

```ruby
Blinkist::Config.env = "production" || "test" || "development"
Blinkist::Config.app_name = "your_app_name" # Used only with diplomat adapter
Blinkist::Config.adapter_type = :diplomat || :env
```

It's best to drop a `config.rb` into your app and load this file before every other file. In Rails you can link it into your `application.rb`

```ruby
require_relative "boot"
require_relative "config"

require "rails"
# ...
```

## Development

You can build this project easily with [docker compose](https://docs.docker.com/compose/).

```
docker-compose run rake
```

This will execute rake and run all specs by auto correcting the code with rubocop.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/blinkist-config.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

