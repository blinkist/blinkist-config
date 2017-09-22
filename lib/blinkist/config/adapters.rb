module Blinkist
  class Config
    module Adapters
      BUILT_IN = {
        env: EnvAdapter,
        diplomat: DiplomatAdapter
      }.freeze
    end
  end
end
