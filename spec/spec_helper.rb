$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "sshpm"

require "faker"
require "docker"
require "net/ssh"
require "sshkey"

module SSHPM
  module Tests
    module Platforms
      Docker = [
        { name: 'Ubuntu 14.04', image: 'sshpm-test-server:ubuntu-1404' },
        { name: 'Ubuntu 16.04', image: 'sshpm-test-server:ubuntu-1604' },
        { name: 'Ubuntu 16.10', image: 'sshpm-test-server:ubuntu-1610' },
        { name: 'Ubuntu 17.04', image: 'sshpm-test-server:ubuntu-1704' },
      ]
    end

    def self.run_docker_container image
      Docker::Container.create(
        'Image' => image,
        'ExposedPorts' => { '22/tcp' => {} },
        'HostConfig' => {
          'PortBindings' => { '22/tcp' => [{}] }
        }
      ).start
    end
  end
end
