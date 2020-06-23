# Blinkist::Config

[![CircleCI](https://circleci.com/gh/blinkist/blinkist-config.svg?style=shield)](https://circleci.com/gh/blinkist/blinkist-config)
[![Code Climate](https://codeclimate.com/github/blinkist/blinkist-config/badges/gpa.svg)](https://codeclimate.com/github/blinkist/blinkist-config)

This GEM allows you to access configuration stores with different adapters. Here're some examples of usage:

### Using the ENV

```ruby
# First setup the Config to use the ENV as config store
Blinkist::Config.env = ENV["RAILS_ENV"]
Blinkist::Config.app_name = "my_nice_app"
Blinkist::Config.adapter_type = :env
Blinkist::Config.error_handler = :strict

my_config_value = Blinkist::Config.get! "some/folder/config"

# This is being translated to ENV["SOME_FOLDER_CONFIG"]
```

### Error handling

When configured with `Blinkist::Config.error_handler = :strict` (as recommended)
reading a configuration entry for which the value is missing 
(for example missing enviroment variables) will cause
`Blinkist::Config::ValueMissingError` to be raised.

There is also an alternative mode `Blinkist::Config.error_handler = :heuristic` which
will raise exceptions only when `Blinkist::Config.env == "production"`.

This alternative mode can be used for backward compatibility.

### Using Diplomat & Consul

If you want to use Consul's key value store, simply use our diplomat adapter.

* [https://www.consul.io/](https://www.consul.io/)
* [https://github.com/WeAreFarmGeek/diplomat](https://github.com/WeAreFarmGeek/diplomat)

The GEM expects consul to listen to `http://172.17.0.1:8500`

```ruby
# First setup the Config to use the ENV as config store
Blinkist::Config.env = ENV["RAILS_ENV"]
Blinkist::Config.app_name = "my_nice_app"
Blinkist::Config.adapter_type = ENV["CONSUL_AVAILABLE"] == "true" ? :diplomat : :env

my_config_value = Blinkist::Config.get! "some/folder/config"

# This is will try to get a value from Consul's KV store at "my_nice_app/some/folder/config"
```

### Using Diplomat with a folder scope
```ruby
# Here we setting a scope outside of the app

my_config_value = Blinkist::Config.get! "another/config", scope: "global"

# This will replace `my_nice_app` with `global` and try to resolve "global/another/config"
# With :env the scope will simply be ignored
```

### Using AWS SSM

If you want to use EC2's key value store SSM, simply use our aws_ssm adapter. It'll automatically try to decrypt all keys.

The GEM expects the code to run in an AWS environment with properly set up IAM.

```ruby
Blinkist::Config.env = ENV["RAILS_ENV"]
Blinkist::Config.app_name = "my_nice_app"
Blinkist::Config.adapter_type = ENV["SSM_AVAILABLE"] == "true" ? :aws_ssm : :env

my_config_value = Blinkist::Config.get! "some/folder/config"

# This is will try to get a parameter from SSM at "/application/my_nice_app/some/folder/config"

# You can also preload all parameters to avoid later calls to SSM
Blinkist::Config.preload
Blinkist::Config.preload scope: "global" # in case you need also another scope being preloaded
```

### Using SSM with a folder scope
```ruby
# Here we setting a scope outside of the app

my_config_value = Blinkist::Config.get! "another/config", scope: "global"

# This will replace `my_nice_app` with `global` and try to resolve "/application/global/another/config"
```

### Why no default values?

Providing default values is not supported by this library (anymore) since such functionality can lead to easy programmer errors.

Most commonly someone forgets to add a config value to the production or stage config store (e.g. AWS SSM) but the systems 
fails silently since it falls back to the default value.
We also saw cases where missing parameters in AWS SSM caused throttling exceptions since a missing parameter cannot be 
cached by this gem and hence is requested over and over again. These throttling also can affect other services in the same AWS account!
[Example incident post mortem](https://blinkist.atlassian.net/wiki/spaces/WEB/pages/1769570440/Postmortem+2020-06-09+SSM+throttling+in+webapp+due+to+Audiobook+import+in+Lambda)

This gem ensures to fail in a way developers will notice by throwing proper errors for missing configuration - latest when deployed to stage.

The more locations there are for a config value to be defined the more complexity and harder to reason about it is. We think having two distinct places is enough:
- `.env` files for local development config
- AWS SSM for production/stage config

## Installation

Add this line to your application's Gemfile:

```ruby
gem "blinkist-config"
```

### Upgrade to v2.X

Version 2.X removes the previously deprecated `Blinkist::Config.get` method. It also removes the possibility to supply a default value in general.
For the reasoning about this change see "Why no default values?" above.

Required code changes:
- `Blinkist::Config.get("yourKey", "yourDefaultValue")` => `Blinkist::Config.get!("yourKey")`
- `Blinkist::Config.get!("yourKey", "yourDefaultValue")` => `Blinkist::Config.get!("yourKey")`

Now also `Blinkist::Config.error_handler = :strict` is the default to throw errors on missing config as early as possible. 
If you really rely on the previous default of `Blinkist::Config.error_handler = :heuristic` please set in your application config.  

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

If you're ready to tag a new version, do this

```
docker-compose run gem bump -t -v major|minor|patch
```

To deploy to rubygems.org do this then

```
docker-compose run gem release
```

You'll have to have proper rights to access rubygems.org

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/blinkist/blinkist-config.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

