require 'spec_helper'
require 'fileutils'

describe WebCache do
  subject { described_class }

  it "has good defaults" do
    expect(subject.dir).to eq 'cache'
    expect(subject.life).to eq 360
  end

  it "is enabled by default" do
    expect(subject).to be_enabled
  end

  it "behaves as a WebCache instance" do
    instance_methods = subject.new.methods - Object.methods
    class_methods    = subject.methods - Object.methods

    expect(instance_methods).to eq class_methods
  end
end