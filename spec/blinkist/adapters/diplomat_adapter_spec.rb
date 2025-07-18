require "spec_helper"

describe Blinkist::Config::DiplomatAdapter do
  subject { adapter }

  let(:env) { "test" }
  let(:app_name) { "my_test_app" }
  let(:adapter) { described_class.new env, app_name }

  it "configures Diplomat" do
    subject
    expect(Diplomat.configuration.url).to eq "http://localhost:8500"
  end

  describe "#get" do
    subject { adapter.get(key, default, scope: scope, refetch: refetch) }

    let(:key) { "my/special/key" }
    let(:default) { "my fallback" }
    let(:diplomat_key) { "#{app_name}/#{key}" }
    let(:consul_value) { "a consul value" }
    let(:scope) { nil }
    let(:refetch) { false }

    before { allow(Diplomat::Kv).to receive(:get).with(diplomat_key).and_return consul_value }

    it { is_expected.to eq consul_value }

    context "when a scope is set" do
      let(:scope) { "super_duper" }
      let(:diplomat_key) { "#{scope}/#{key}" }

      it { is_expected.to eq consul_value }
    end

    context "when the key has being asked before" do
      before { adapter.get(key, default, scope: scope) }

      it "doesn't call Diplomat a second time" do
        expect(Diplomat::Kv).to_not receive(:get)
        subject
      end
    end

    it "maintains caching behavior alongside refetch functionality" do
      # First call should cache the value
      first_value = adapter.get(key, default, scope: scope)

      # Second call without refetch should use cache (no additional Consul call)
      second_value = adapter.get(key, default, scope: scope)
      expect(second_value).to eq first_value

      # Third call with refetch should bypass cache and call Consul again
      allow(Diplomat::Kv).to receive(:get).with(diplomat_key).and_return("refreshed value")
      third_value = adapter.get(key, default, scope: scope, refetch: true)
      expect(third_value).to eq "refreshed value"

      # Fourth call without refetch should use the newly cached value (no additional Consul call)
      fourth_value = adapter.get(key, default, scope: scope)
      expect(fourth_value).to eq "refreshed value"

      # Should have called Consul exactly twice: once for initial load, once for refetch
      expect(Diplomat::Kv).to have_received(:get).exactly(2).times
    end

    it "calls Consul every time with refetch: true" do
      expect(Diplomat::Kv).to receive(:get).exactly(3).times
      3.times { adapter.get(key, default, scope: scope, refetch: true) }
    end

    context "when there's an Diplomat::KeyNotFound error" do
      before { allow(Diplomat::Kv).to receive(:get).with(diplomat_key).and_raise Diplomat::KeyNotFound }

      it { is_expected.to eq default }
    end
  end
end
