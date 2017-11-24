module Blinkist
  class Config
    module Adapters
      BUILT_IN = {
        env: EnvAdapter,
        diplomat: DiplomatAdapter,
        aws_ssm: AwsSsmAdapter
      }.freeze
    end
  end
end
