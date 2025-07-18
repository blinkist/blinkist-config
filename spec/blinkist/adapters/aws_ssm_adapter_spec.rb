require "spec_helper"

describe Blinkist::Config::AwsSsmAdapter do
  subject { adapter }

  let(:env) { "test" }
  let(:app_name) { "abtester" }
  let(:adapter) { described_class.new env, app_name }
  let(:ssm_client) { instance_double Aws::SSM::Client }

  before { allow(Aws::SSM::Client).to receive(:new).and_return ssm_client }

  describe "#get" do
    subject { adapter.get(key, default, scope: scope, refetch: refetch) }

    let(:key) { "database_url" }
    let(:default) { "my fallback" }
    let(:scope) { nil }
    let(:refetch) { false }
    let(:value) { "some value #{rand}" }

    before do
      allow(ssm_client).to receive(:get_parameter).and_return(instance_double(Aws::SSM::Types::GetParameterResult,
        parameter: instance_double(
          Aws::SSM::Types::Parameter, value: value
        )))
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

    it "maintains caching behavior alongside refetch functionality" do
      # First call should cache the value
      first_value = adapter.get(key, default, scope: scope)

      # Second call without refetch should use cache (no additional SSM call)
      second_value = adapter.get(key, default, scope: scope)
      expect(second_value).to eq first_value

      # Third call with refetch should bypass cache and call SSM again
      allow(ssm_client).to receive(:get_parameter).and_return(instance_double(Aws::SSM::Types::GetParameterResult,
        parameter: instance_double(
          Aws::SSM::Types::Parameter, value: "refreshed value"
        )))
      third_value = adapter.get(key, default, scope: scope, refetch: true)
      expect(third_value).to eq "refreshed value"

      # Fourth call without refetch should use the newly cached value (no additional SSM call)
      fourth_value = adapter.get(key, default, scope: scope)
      expect(fourth_value).to eq "refreshed value"

      # Should have called SSM exactly twice: once for initial load, once for refetch
      expect(ssm_client).to have_received(:get_parameter).exactly(2).times
    end

    it "calls SSM every time with refetch: true" do
      expect(ssm_client).to receive(:get_parameter).exactly(3).times
      3.times { adapter.get(key, default, scope: scope, refetch: true) }
    end

    context "with an Aws::SSM::Errors::ParameterNotFound" do
      before do
        allow(ssm_client).to receive(:get_parameter).and_raise(Aws::SSM::Errors::ParameterNotFound.new("context",
          "message"))
      end

      it { is_expected.to eq default }
    end
  end

  describe "#preload" do
    subject { adapter }

    let(:next_token) { nil }
    let(:result) { double(parameters: parameters, next_token: next_token) }
    let(:parameters) do
      [double(name: "/application/#{app_name}/test", value: "value")]
    end

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
