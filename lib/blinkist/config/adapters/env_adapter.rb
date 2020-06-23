require_relative "adapter"

module Blinkist
  class Config
    class EnvAdapter < Adapter
      def get(key, **)
        env_key = key.tr("/", "_").upcase
        ENV[env_key] || nil
      end
    end
  end
end
