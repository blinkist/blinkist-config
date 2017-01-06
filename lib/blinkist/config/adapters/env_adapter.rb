require_relative "adapter"

module Blinkist
  class Config
    class EnvAdapter < Adapter
      def get(key, default = nil, **)
        env_key = key.tr("/", "_").upcase
        ENV[env_key] || default
      end
    end
  end
end
