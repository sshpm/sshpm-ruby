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

    def self.run_docker_container(image)
      Docker::Container.create(
        'Image' => image,
        'ExposedPorts' => { '22/tcp' => {} },
        'HostConfig' => {
          'PortBindings' => { '22/tcp' => [{}] }
        }
      ).start
    end

    def self.ssh_password_options(opts={})
      {
        password: opts[:password] || 'test_password',
        port: opts[:port] || '22',
        non_interactive: opts[:non_interactive] || true,
        paranoid: opts[:paranoid] || false
      }
    end

    def self.ssh_identity_options(opts={})
      {
        keys: opts[:keys] || [],
        key_data: opts[:key_data],
        keys_only: opts[:keys_only] || true,
        port: opts[:port] || @port,
        non_interactive: opts[:non_interactive] || true,
        paranoid: opts[:paranoid] || false
      }
    end
  end
end
