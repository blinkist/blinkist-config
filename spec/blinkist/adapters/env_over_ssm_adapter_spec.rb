require "spec_helper"

describe Blinkist::Config::EnvOverSsmAdapter do
  subject { adapter }

  let(:env) { "test" }
  let(:app_name) { "my_test_app" }
  let(:adapter) { described_class.new env, app_name }
  let(:ssm_client) { instance_double Aws::SSM::Client }

  before { allow(Aws::SSM::Client).to receive(:new).and_return ssm_client }

  describe "#get" do
    subject { adapter.get(key, default, scope: scope, refetch: refetch) }

    let(:key) { "my/special/key" }
    let(:env_key) { "MY_SPECIAL_KEY" }
    let(:default) { "my fallback" }
    let(:scope) { nil }
    let(:refetch) { false }
    let(:ssm_value) { "ssm value" }

    before do
      allow(ssm_client).to receive(:get_parameter).and_return(instance_double(Aws::SSM::Types::GetParameterResult,
        parameter: instance_double(Aws::SSM::Types::Parameter, value: ssm_value)))
    end

    context "when the ENV has a value" do
      before { ENV[env_key] = "env value" }
      after { ENV.delete env_key }

      it { is_expected.to eq "env value" }

      it "does not call SSM" do
        subject
        expect(ssm_client).not_to have_received(:get_parameter)
      end
    end

    context "when the ENV has no value" do
      it { is_expected.to eq ssm_value }

      it "asks SSM with the app scope" do
        subject
        expect(ssm_client).to have_received(:get_parameter).with(
          name: "/application/#{app_name}/#{key}",
          with_decryption: true
        )
      end

      context "with a scope" do
        let(:scope) { "global" }

        it "asks SSM with the given scope" do
          subject
          expect(ssm_client).to have_received(:get_parameter).with(
            name: "/application/#{scope}/#{key}",
            with_decryption: true
          )
        end
      end

      context "with refetch: true" do
        let(:refetch) { true }

        it "calls SSM every time" do
          3.times { adapter.get(key, default, scope: scope, refetch: true) }
          expect(ssm_client).to have_received(:get_parameter).exactly(3).times
        end
      end

      context "when SSM has no value either" do
        before do
          allow(ssm_client).to receive(:get_parameter)
            .and_raise(Aws::SSM::Errors::ParameterNotFound.new("context", "message"))
        end

        it { is_expected.to eq default }
      end
    end
  end

  describe "#preload" do
    let(:result) { double(parameters: [double(name: "/application/#{app_name}/test", value: "value")], next_token: nil) }

    before { allow(ssm_client).to receive(:get_parameters_by_path).and_return result }

    it "preloads SSM values" do
      adapter.preload

      expect(ssm_client).not_to receive(:get_parameter)
      expect(adapter.get("test")).to eq "value"
    end
  end
end
