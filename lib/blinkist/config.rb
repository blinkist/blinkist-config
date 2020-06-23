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
require_relative "config/adapters/aws_ssm_adapter"
require_relative "config/adapters"

module Blinkist
  class Config
    class << self
      attr_accessor :adapter_type, :logger, :env, :app_name, :error_handler

      def preload(scope: nil)
        adapter.preload scope: scope
      end

      def get!(key, scope: nil)
        from_adapter = adapter.get(key, scope: scope)

        if from_adapter.nil?
          handle_error(key, scope)
        else
          from_adapter
        end
      end

      def adapter
        @adapter ||= Factory.new("Blinkist::Config.adapter_type", Adapters::BUILT_IN).call(adapter_type)
      end

      def handle_error(key, scope)
        handler = Factory.new("Blinkist::Config.error_handler", ErrorHandlers::BUILT_IN).call(error_handler)
        handler.call(key, scope)
      end

    end

    # NOTE: default configuration goes here
    self.error_handler = :strict
  end
end
