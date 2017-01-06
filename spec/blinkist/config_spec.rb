require 'spec_helper'

describe Blinkist::Config do
  it 'has a version number' do
    expect(Blinkist::Config::VERSION).not_to be nil
  end

  it 'does something useful' do
    expect(false).to eq(true)
  end

  it "lalal" do
    Blinkist::Config.app_name = "test"
    Blinkist::Config.env = "production"
    Blinkist::Config.adapter_type = :diplomat
    Blinkist::Config.get "test"
  end
end
