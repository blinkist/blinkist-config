require "spec_helper"

describe Blinkist::Config::ValueMissingError do
  subject { described_class }

  it { is_expected.to be < ::StandardError }
  it { is_expected.to be < Blinkist::Config::Error }
end
