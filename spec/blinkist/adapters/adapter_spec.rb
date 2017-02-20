require "spec_helper"

describe Blinkist::Config::Adapter do
  subject { described_class.new env, app_name }

  let(:env) { "test" }
  let(:app_name) { "some_app" }

  it "assigns @env" do
    expect(subject.instance_variable_get("@env")).to eq env
  end

  it "assigns @app_name" do
    expect(subject.instance_variable_get("@app_name")).to eq app_name
  end

  describe ".instance_for" do
    subject { described_class.instance_for type, env, app_name }

    let(:env) { { "some" => "value" } }
    let(:app_name) { "my_app_name" }

    context "for type is :env" do
      let(:type) { :env }

      it { is_expected.to be_a Blinkist::Config::EnvAdapter }

      it "initializes the EnvAdapter properly" do
        expect(Blinkist::Config::EnvAdapter).to receive(:new).with(env, app_name)

        subject
      end
    end

    context "for type is :diplomat" do
      let(:type) { :diplomat }

      it { is_expected.to be_a Blinkist::Config::DiplomatAdapter }

      it "initializes the DiplomatAdapter properly" do
        expect(Blinkist::Config::DiplomatAdapter).to receive(:new).with(env, app_name)

        subject
      end
    end
  end
end
