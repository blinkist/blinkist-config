require "spec_helper"

describe Blinkist::Config::DiplomatAdapter do
  subject { described_class.new env, app_name }

  let(:env) { "test" }
  let(:app_name) { "my_test_app" }

  it "configures Diplomat" do
    subject
    expect(Diplomat.configuration.url).to eq "http://172.17.0.1:8500"
  end

  describe "#get" do
    subject { super().get(key, default, scope: scope) }

    let(:key) { "my/special/key" }
    let(:default) { "my fallback" }
    let(:diplomat_key) { "#{app_name}/#{key}" }
    let(:consul_value) { "a consul value" }
    let(:scope) { nil }

    before { allow(Diplomat::Kv).to receive(:get).with(diplomat_key).and_return consul_value }

    it { is_expected.to eq consul_value }

    context "when a scope is set" do
      let(:scope) { "super_duper" }
      let(:diplomat_key) { "#{scope}/#{key}" }

      it { is_expected.to eq consul_value }
    end

    context "when the key has being asked before" do
      before { subject }

      it "doesn't call Diplomat a second time" do
        expect(Diplomat::Kv).to_not receive(:get)
        subject
      end
    end

    context "when there's an Diplomat::KeyNotFound error" do
      before { allow(Diplomat::Kv).to receive(:get).with(diplomat_key).and_raise Diplomat::KeyNotFound }

      it { is_expected.to eq default }
    end
  end
end
