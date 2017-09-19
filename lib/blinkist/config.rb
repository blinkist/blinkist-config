require_relative "config/version"
require_relative "config/error"
require_relative "config/errors/not_implemented_error"
require_relative "config/errors/value_missing_error"
require_relative "config/adapters/env_adapter"
require_relative "config/adapters/diplomat_adapter"

module Blinkist
  class Config
    class << self
      attr_accessor :adapter_type, :logger, :env, :app_name

      def get(key, default = nil, scope: nil)
        adapter.get(key, scope: scope) || default
      end

      def adapter
        @adapter ||= Adapter.instance_for adapter_type, env, app_name
      end
    end
  end
end
