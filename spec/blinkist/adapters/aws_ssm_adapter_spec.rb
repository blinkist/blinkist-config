require "spec_helper"

describe Blinkist::Config::AwsSsmAdapter do
  subject { adapter }

  let(:env) { "test" }
  let(:app_name) { "abtester" }
  let(:adapter) { described_class.new env, app_name }
  let(:aws_region) { "eu-west-1" }

  before do
    described_class.aws_region = aws_region
  end

  describe "#get" do
    subject { adapter.get(key, default, scope: scope) }

    let(:key) { "database_url" }
    let(:default) { "my fallback" }
    let(:scope) { nil }

    before { adapter.preload scope: "global" }

    it "test" do
      puts subject
    end
  end

  describe "#preload" do
    subject { adapter.preload }

    it "test" do
      puts subject
    end
  end
end
