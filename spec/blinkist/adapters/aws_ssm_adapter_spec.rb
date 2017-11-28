require "spec_helper"

describe Blinkist::Config::AwsSsmAdapter do
  subject { adapter }

  let(:env) { "test" }
  let(:app_name) { "abtester" }
  let(:adapter) { described_class.new env, app_name }
  let(:ssm_client) { instance_double Aws::SSM::Client }

  before { allow(Aws::SSM::Client).to receive(:new).and_return ssm_client }

  describe "#get" do
    subject { adapter.get(key, default, scope: scope) }

    let(:key) { "database_url" }
    let(:default) { "my fallback" }
    let(:scope) { nil }
    let(:value) { "some value #{rand}" }

    before do
      allow(ssm_client).to receive_message_chain(:get_parameter, :parameter, :value).and_return value
    end

    it { is_expected.to eq value }

    it "calls with all required params" do
      expect(ssm_client).to receive(:get_parameter).with(
        name: "/application/#{app_name}/#{key}",
        with_decryption: true
      )

      subject
    end

    it "only loads a parameter if it's not cached" do
      expect(ssm_client).to receive(:get_parameter).once
      10.times { adapter.get(key, default, scope: scope) }
    end

    context "with an Aws::SSM::Errors::ParameterNotFound" do
      before do
        allow(ssm_client).to receive_message_chain(
          :get_parameter, :parameter, :value
        ).and_raise(Aws::SSM::Errors::ParameterNotFound.new("context", "message"))
      end

      it { is_expected.to eq default }
    end
  end

  describe "#preload" do
    subject { adapter }

    let(:next_token) { nil }
    let(:result) { double(parameters: parameters, next_token: next_token) }
    let(:parameters) {
      [double(name: "/application/#{app_name}/test", value: "value")]
    }

    before do
      allow(ssm_client).to receive(:get_parameters_by_path).and_return result
    end

    it "preloads all values" do
      adapter.preload

      expect(ssm_client).to_not receive(:get_parameter)
      subject.get "test"
    end

    it "calls with all required params" do
      expect(ssm_client).to receive(:get_parameters_by_path).with(
        path: "/application/#{app_name}/",
        recursive: true,
        with_decryption: true,
        next_token: next_token
      )

      adapter.preload
    end
  end
end
