
module Blinkist
  class Config
    module ErrorHandlers
      BUILT_IN = {
        strict: ErrorHandler,
        heuristic: ProductionOnlyErrorHandler
      }.freeze
    end
  end
end
