module Blinkist
  class Config
    module Adapters
      BUILT_IN = {
        env: EnvAdapter,
        diplomat: DiplomatAdapter,
        aws_ssm: AwsSsmAdapter,
        env_over_ssm: EnvOverSsmAdapter
      }.freeze
    end
  end
end
