require_relative "config/version"
require_relative "config/error"
require_relative "config/factory"
require_relative "config/not_implemented_error"
require_relative "config/invalid_strategy_error"
require_relative "config/value_missing_error"
require_relative "config/error_handlers/error_handler"
require_relative "config/error_handlers/production_only_error_handler"
require_relative "config/error_handlers"
require_relative "config/adapters/env_adapter"
require_relative "config/adapters/diplomat_adapter"

module Blinkist
  class Config
    class << self
      attr_accessor :adapter_type, :logger, :env, :app_name, :errors

      def get(key, default = nil, scope: nil)
        adapter.get(key, scope: scope) || default
      end

      def adapter
        @adapter ||= Adapter.instance_for adapter_type, env, app_name

      def handle_error(key, scope)
        handler = Factory.new("Blinkist::Config.errors", ErrorHandlers::BUILT_IN).call(errors)
        handler.call(key, scope)
      end

    end

    # NOTE: default configuration goes here
    self.errors = :heuristic
  end
end
