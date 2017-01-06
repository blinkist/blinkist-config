module Blinkist
  class Config
    class Adapter
      def initialize(env, app_name)
        @env = env
        @app_name = app_name
      end

      def get(_key, _default=nil, **)
        raise NotImplementedError
      end

      class << self
        def instance_for(type, env, app_name)
          case type
          when :env
            EnvAdapter.new env, app_name
          when :diplomat
            DiplomatAdapter.new env, app_name
          else
            raise NotImplementedError
          end
        end
      end
    end
  end
end
