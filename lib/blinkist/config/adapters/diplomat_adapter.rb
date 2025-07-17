require_relative "adapter"
require "diplomat"

module Blinkist
  class Config
    class DiplomatAdapter < Adapter
      def initialize(env, app_name)
        super

        @items_cache = {}
      end

      def get(key, default=nil, scope: nil, refetch: false)
        scope ||= @app_name

        diplomat_key = "#{scope}/#{key}"

        @items_cache[diplomat_key] = Diplomat::Kv.get(diplomat_key) if refetch || !@items_cache.key?(diplomat_key)

        @items_cache[diplomat_key]
      rescue Diplomat::KeyNotFound
        default
      end
    end
  end
end
