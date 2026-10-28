# Blinkist::Config

Read configuration values through one interface, backed by the store you pick: the process ENV, AWS SSM Parameter Store, Consul (via Diplomat), or ENV with an SSM fallback.

## Installation

```ruby
gem "blinkist-config"
```

## Setup

Configure the gem once, before anything else loads. In Rails, put this in a `config.rb` and require it from `application.rb` right after `boot`.

```ruby
Blinkist::Config.env = ENV["RAILS_ENV"]
Blinkist::Config.app_name = "my_nice_app"
Blinkist::Config.adapter_type = :env # :env, :aws_ssm, :env_over_ssm or :diplomat
Blinkist::Config.error_handler = :strict
```

## Reading values

```ruby
Blinkist::Config.get! "some/folder/config"
```

With `:env` this reads `ENV["SOME_FOLDER_CONFIG"]`. With `:aws_ssm` it reads `/application/my_nice_app/some/folder/config`. With `:diplomat` it reads `my_nice_app/some/folder/config`.

### Default value

Pass a default as the second argument. Then a missing value returns the default instead of raising.

```ruby
Blinkist::Config.get! "some/folder/config", "default value"
```

### Scope

A scope replaces the app name in the key path. The `:env` adapter ignores it.

```ruby
Blinkist::Config.get! "another/config", scope: "global"
# aws_ssm: /application/global/another/config
# diplomat: global/another/config
```

### Refetch

Values are cached after the first read. Pass `refetch: true` to read from the store again. This costs SSM quota, so use it with care.

```ruby
Blinkist::Config.get! "some/folder/config", refetch: true
```

### Error handling

- `:strict` raises `Blinkist::Config::ValueMissingError` when a value is missing. Recommended.
- `:heuristic` raises only when `env == "production"`. This is the default for backwards compatibility.

## Adapters

### `:env`

Reads from `ENV`. The key is upcased and `/` becomes `_`.

### `:aws_ssm`

Reads from AWS SSM Parameter Store with decryption. The code must run with IAM access to the parameters.

```ruby
Blinkist::Config.adapter_type = :aws_ssm

# Load all parameters of a scope in one call to avoid later lookups
Blinkist::Config.preload
Blinkist::Config.preload scope: "global"
```

### `:env_over_ssm`

Reads from `ENV` first. When the ENV has no value, it falls back to SSM. This lets you override single SSM values locally or in CI without touching the parameter store.

```ruby
Blinkist::Config.adapter_type = :env_over_ssm

Blinkist::Config.get! "database/url"
# 1. ENV["DATABASE_URL"] if set
# 2. otherwise /application/my_nice_app/database/url from SSM
```

`scope`, `refetch` and `preload` apply to the SSM part only.

### `:diplomat`

Reads from Consul's key value store through [Diplomat](https://github.com/WeAreFarmGeek/diplomat). Configure Diplomat yourself before use.

```ruby
Diplomat.configure do |config|
  config.url = "http://172.17.0.1:8500"
end

Blinkist::Config.adapter_type = :diplomat
```

## Development

Requires [Task](https://taskfile.dev) and Docker.

```sh
task bundle       # install gems for all supported Ruby versions
task test         # run specs on all supported Ruby versions
task test:local   # run specs on the default Ruby version
task test:3.4     # run specs on one Ruby version
task lint         # run StandardRB
task shell        # open a shell in the container
```

## Release

1. Bump `VERSION` in `lib/blinkist/config/version.rb`. The `version-guard` workflow fails a PR to `main` without a bump.
2. Merge to `main`. The `tag-release` workflow creates the git tag and the GitHub release.
3. Push to rubygems.org:

```sh
task run -- gem build blinkist-config.gemspec
task run -- gem push blinkist-config-x.y.z.gem
```

## License

MIT, see [LICENSE](LICENSE).
