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

      def preload(**)
        raise NotImplementedError
      end

      class << self
        def instance_for(type, env, app_name)
          Factory.new("Blinkist::Adapter.for", Adapters::BUILT_IN, env, app_name).call(type)
        end

        extend Gem::Deprecate
        deprecate :instance_for, :none, 2017, 12
      end
    end
  end
end
