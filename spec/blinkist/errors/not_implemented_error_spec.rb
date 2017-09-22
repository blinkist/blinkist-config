require "spec_helper"

describe Blinkist::Config::NotImplementedError do
  subject { described_class }

  it { is_expected.to be < ::StandardError }
  it { is_expected.to be < Blinkist::Config::Error }
  it { is_expected.not_to eq ::NotImplementedError }
end
