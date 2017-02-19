require "spec_helper"
require "docker"

describe SSHPM do
  it "has a version number" do
    expect(SSHPM::VERSION).not_to be nil
  end
end
