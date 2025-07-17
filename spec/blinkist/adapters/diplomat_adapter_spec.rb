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

    context "when refetch is true" do
      let(:refetch) { true }
      let(:new_consul_value) { "updated consul value" }

      it "reloads the value from Consul even if cached" do
        # First call to cache the value
        first_value = adapter.get(key, default, scope: scope)

        # Second call should get a new value due to refetch: true
        allow(Diplomat::Kv).to receive(:get).with(diplomat_key).and_return(new_consul_value)
        second_value = adapter.get(key, default, scope: scope, refetch: true)

        expect(second_value).to eq new_consul_value
        expect(second_value).not_to eq first_value
      end

      it "calls Consul every time with refetch: true" do
        expect(Diplomat::Kv).to receive(:get).exactly(3).times
        3.times { adapter.get(key, default, scope: scope, refetch: true) }
      end
    end

    context "when there's an Diplomat::KeyNotFound error" do
      before { allow(Diplomat::Kv).to receive(:get).with(diplomat_key).and_raise Diplomat::KeyNotFound }

      it { is_expected.to eq default }
    end
  end
end
