require "spec_helper"

describe Blinkist::Config do
  it "has a version number" do
    expect(Blinkist::Config::VERSION).not_to be nil
  end

  describe ".error_handler" do
    subject { Blinkist::Config.error_handler }

    it { is_expected.to eq :heuristic }
  end

  describe ".get" do
    subject { described_class.get key, default, scope: scope }

    let(:key) { "my_key" }
    let(:scope) { nil }
    let(:default) { "some default" }
    let(:notifier) { nil }
    let(:value) { "1234" }
    let(:adapter) { instance_double Blinkist::Config::Adapter, get: value }

    before do
      allow(Blinkist::Config).to receive(:adapter).and_return adapter
      described_class.notifier = notifier
    end

    after do
      described_class.notifier = nil
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

      context "with a notifier provided" do
        let(:notifier) { double("notifier") }

        it "notifies" do
          expect(notifier).to receive(:notify).with("Missing config value from adapter 'RSpec::Mocks::InstanceVerifyingDouble' for key 'my_key' in scope ''. This can lead to AWS SSM throttling issues in production! Make sure to provide values for all config keys!")
          subject
        end
      end
    end
  end

  describe ".get!" do
    let(:value)   { "1234" }
    let(:scope)   { nil }
    let(:adapter) { instance_double Blinkist::Config::Adapter }
    let(:key)     { "some_valid_key" }

    before do
      allow(Blinkist::Config).to receive(:adapter).and_return(adapter)
      allow(Blinkist::Config).to receive(:error_handler).and_return(:strict)
      allow(adapter).to receive(:get).with(key, scope: scope).and_return(value)
    end

    context "when called with too many arguments" do
      it "raises an error" do
        expect { described_class.get!(1, 2, 3) }.to raise_error(ArgumentError, /wrong number of arguments/)
      end
    end

    context "with a valid key" do
      subject { described_class.get!(key) }

      it { is_expected.to eq(value) }

      context "and no scope" do
        let(:scope) { nil }

        subject { described_class.get!(key) }

        it { is_expected.to eq(value) }
      end

      context "and a valid scope" do
        let(:scope) { "some_other_scope" }

        subject { described_class.get!(key, scope: scope) }

        it { is_expected.to eq(value) }
      end

      context "and an invalid scope" do
        let(:scope) { "some_valid_scope" }
        let(:invalid) { "some_invalid_scope" }

        before { allow(adapter).to receive(:get).with(key, scope: invalid).and_return(nil) }

        subject { described_class.get!(key, scope: invalid) }

        it "is expected to raise an error" do
          expect { subject }.to raise_error(Blinkist::Config::ValueMissingError)
        end

        context "and a default value" do
          let(:scope)   { "some_valid_scope" }
          let(:default) { "default value" }

          subject { described_class.get!(key, default, scope: invalid) }

          it { is_expected.to eq(default) }
        end
      end
    end

    context "with an invalid key" do
      let(:invalid) { "invalid_key" }

      before { allow(adapter).to receive(:get).with(invalid, scope: scope).and_return(nil) }

      subject { described_class.get!(invalid, scope: scope) }

      it "is expected to raise an error" do
        expect { subject }.to raise_error(Blinkist::Config::ValueMissingError)
      end

      context "and a default value" do
        let(:default) { "default value" }

        subject { described_class.get!("invalid_key", default) }

        it { is_expected.to eq(default) }
      end

      context "and a default value of nil" do
        let(:default) { nil }

        subject { described_class.get!("invalid_key", default) }

        it { is_expected.to eq(default) }
      end
    end
  end

  describe ".adapter" do
    let(:fake_adapter) { instance_double Blinkist::Config::Adapter }
    let(:env) { "some_env" }
    let(:app_name) { "app_name " }

    before do
      allow(Blinkist::Config).to receive(:adapter_type).and_return(adapter_type)
      allow(Blinkist::Config).to receive(:env).and_return(env)
      allow(Blinkist::Config).to receive(:app_name).and_return(app_name)
      described_class.instance_variable_set(:@adapter, nil)
    end

    context "with :env adapter type" do
      let(:adapter_type) { :env }

      it "constructs Blinkist::Config::EnvAdapter" do
        allow(Blinkist::Config::EnvAdapter).to receive(:new).and_return(fake_adapter)
        expect(described_class.adapter).to eq(fake_adapter)
      end
    end

    context "with :diplomat adapter type" do
      let(:adapter_type) { :diplomat }

      it "constructs Blinkist::Config::DiplomatAdapter" do
        allow(Blinkist::Config::DiplomatAdapter).to receive(:new).and_return(fake_adapter)
        expect(described_class.adapter).to eq(fake_adapter)
      end
    end
  end

  describe ".handle_error" do
    let(:key) { "some_key" }
    let(:scope) { "some_scope" }
    let(:env) { nil }

    before do
      allow(described_class).to receive(:error_handler).and_return(strategy)
      allow(described_class).to receive(:env).and_return(env)
    end

    context "with :strict strategy" do
      let(:strategy) { :strict }

      it "always throws an error" do
        expect { described_class.handle_error(key, scope) }.to raise_error(Blinkist::Config::ValueMissingError, /check the configuration/i)
      end
    end

    context "with :heuristic strategy" do
      let(:strategy) { :heuristic }

      context "when env is setup to production" do
        let(:env) { "production" }

        it "throws an error" do
          expect { described_class.handle_error(key, scope) }.to raise_error(Blinkist::Config::ValueMissingError, /check the configuration/i)
        end
      end

      context "when env is not set" do
        let(:env) { nil }

        it "does not raise an error" do
          expect { described_class.handle_error(key, scope) }.not_to raise_error
        end
      end

      context "when env is set to any other value" do
        let(:env) { 42 }

        it "does not raise an error" do
          expect { described_class.handle_error(key, scope) }.not_to raise_error
        end
      end
    end

    context "with a lambda strategy" do
      let(:custom_lambda) { ->(*args) {} }
      let(:strategy) { custom_lambda }

      it "calls the lambda for error handling" do
        expect(custom_lambda).to receive(:call).with(key, scope)
        described_class.handle_error(key, scope)
      end
    end

    context "with a custom class strategy" do
      let(:custom_class) { Class.new }
      let(:instance) { instance_double("ErrorHandler") }
      let(:strategy) { custom_class }

      it "instantiates and calls the strategy" do
        expect(custom_class).to receive(:new).with(Blinkist::Config.env, Blinkist::Config.app_name).and_return(instance)
        expect(instance).to receive(:call).with(key, scope)
        described_class.handle_error(key, scope)
      end
    end

    context "with something wonky" do
      let(:strategy) { 42r }

      it "raises an error" do
        expect { described_class.handle_error(key, scope) }.to raise_error(Blinkist::Config::InvalidStrategyError)
      end
    end
  end
end
