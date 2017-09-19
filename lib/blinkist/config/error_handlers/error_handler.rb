module Blinkist
  class Config
    class ErrorHandler
      def initialize(env, app_name)
        @env = env
        @app_name = app_name
      end

      def call(key, scope)
        raise ValueMissingError, "Missing value for #{key} in the scope: #{scope || '<default>'} (Please check the configuration for missing keys)"
      end
    end
  end
end
