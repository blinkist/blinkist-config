require_relative "adapter"
require "diplomat"

module Blinkist
  class Config
    class DiplomatAdapter < Adapter
      def initialize(env, app_name)
        super env, app_name

        Diplomat.configure do |config|
          config.url = "http://172.17.0.1:8500"
        end
      end

      def get(key, default=nil, scope: nil)
        scope ||= @app_name

        Diplomat::Kv.get "#{scope}/#{key}"
      rescue Diplomat::KeyNotFound
        default
      end
    end
  end
end
