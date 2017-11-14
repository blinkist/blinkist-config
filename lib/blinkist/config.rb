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

      def get(key, default = nil, scope: nil)
        get!(key, default, scope: scope)
      end

      extend Gem::Deprecate
      deprecate :get, "get!", 2017, 12

      def get!(key, *args, scope: nil)
        # NOTE: we need to do this this way
        # to handle 'nil' default correctly
        case args.length
        when 0
          default = nil
          bang    = true
        when 1
          default = args.first
          bang    = false
        else
          raise ArgumentError, "wrong number of arguments (given #{args.length + 1}, expected 1..2)"
        end

        from_adapter = adapter.get(key, scope: scope)

        if from_adapter.nil? && bang
          handle_error(key, scope)
        else
          return from_adapter || default
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
    self.error_handler = :heuristic
  end
end
