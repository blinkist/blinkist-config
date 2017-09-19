require "spec_helper"

describe Blinkist::Config do
  it "has a version number" do
    expect(Blinkist::Config::VERSION).not_to be nil
  end

  describe ".errors" do
    subject { Blinkist::Config.errors }

    it { is_expected.to eq :heuristic }
  end

  describe ".get" do
    subject { described_class.get key, default, scope: scope }

    let(:key) { "my_key" }
    let(:scope) { nil }
    let(:default) { "some default" }
    let(:value) { "1234" }
    let(:adapter) { instance_double Blinkist::Config::Adapter, get: value }

    before do
      allow(Blinkist::Config).to receive(:adapter).and_return adapter
    end

    it { is_expected.to eq value }

    context "with some scope" do
      let(:scope) { "my/scope" }

      it "passes the scope to the adapter" do
        expect(adapter).to receive(:get).with(key, scope: scope).and_return value
        expect(subject).to eq value
      end
    end

    context "with a nil value being returned from the adapter" do
      let(:value) { nil }

      it { is_expected.to eq default }
    end
  end

  describe ".adapter" do
    subject { described_class.adapter }

    let(:adapter_type) { "some_type" }
    let(:env) { "testing" }
    let(:app_name) { "my_test_app" }
    let(:value) { "1234" }
    let(:adapter) { instance_double Blinkist::Config::Adapter, get: value }

    before do
      allow(Blinkist::Config).to receive(:adapter_type).and_return adapter_type
      allow(Blinkist::Config).to receive(:env).and_return env
      allow(Blinkist::Config).to receive(:app_name).and_return app_name
      allow(Blinkist::Config::Adapter).to receive(:instance_for).with(adapter_type, env, app_name).and_return adapter
    end

    it { is_expected.to be adapter }
  end
end
