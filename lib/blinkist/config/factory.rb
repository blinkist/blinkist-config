module Blinkist
  class Config
    class Factory
      def initialize(aspect, implementations, env=Blinkist::Config.env, app_name=Blinkist::Config.app_name)
        @aspect = aspect
        @implementations = implementations
        @env = env
        @app_name = app_name
      end

      def call(strategy)
        case strategy
        when Symbol
          klass = @implementations[strategy] ||
                  raise(NotImplementedError, "Unknown strategy #{strategy} for #{@aspect}")
        when Class
          klass = strategy
        else
          if strategy.respond_to?(:call)
            return strategy
          else
            raise InvalidStrategyError
          end
        end

        klass.new(@env, @app_name)
      end
    end
  end
end
