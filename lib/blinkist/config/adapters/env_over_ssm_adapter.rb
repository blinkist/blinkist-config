require_relative "adapter"
require_relative "env_adapter"
require_relative "aws_ssm_adapter"

module Blinkist
  class Config
    class EnvOverSsmAdapter < Adapter
      def initialize(env, app_name)
        super

        @env_adapter = EnvAdapter.new(env, app_name)
        @ssm_adapter = AwsSsmAdapter.new(env, app_name)
      end

      def get(key, default = nil, scope: nil, refetch: false)
        @env_adapter.get(key) || @ssm_adapter.get(key, default, scope: scope, refetch: refetch)
      end

      def preload(scope: nil)
        @ssm_adapter.preload(scope: scope)
      end
    end
  end
end
