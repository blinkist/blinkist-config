module Blinkist
  class Config
    class ProductionOnlyErrorHandler < ErrorHandler
      def call(key, scope)
        super if @env.to_s == "production"
      end
    end
  end
end
