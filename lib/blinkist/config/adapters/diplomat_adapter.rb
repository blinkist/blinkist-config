require_relative "adapter"
require "diplomat"

module Blinkist
  class Config
    class DiplomatAdapter < Adapter
      def initialize(env, app_name)
        super env, app_name

        @items_cache = {}
      end

      def get(key, default=nil, scope: nil)
        scope ||= @app_name

        diplomat_key = "#{scope}/#{key}"

        unless @items_cache.key? diplomat_key
          @items_cache[diplomat_key] = Diplomat::Kv.get(diplomat_key)
        end

        @items_cache[diplomat_key]
      rescue Diplomat::KeyNotFound
        default
      end
    end
  end
end
