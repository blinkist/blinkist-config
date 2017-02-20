require "spec_helper"

describe Blinkist::Config::EnvAdapter do
  subject { described_class.new env, app_name }

  let(:env) { "test" }
  let(:app_name) { "my_test_app" }

  describe "#get" do
    subject { super().get(key, default) }

    let(:key) { "my/special/key" }
    let(:env_key) { "MY_SPECIAL_KEY" }
    let(:env_value) { "test value" }
    let(:default) { "my fallback" }

    before { ENV[env_key] = env_value }
    after { ENV.delete env_key }

    it { is_expected.to eq env_value }

    context "with the ENV being nil" do
      let(:env_value) { nil }

      it { is_expected.to eq default }
    end
  end
end
