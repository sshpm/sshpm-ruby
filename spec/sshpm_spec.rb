require "spec_helper"
require "docker"
require "net/ssh"

describe SSHPM do
  it "has a version number" do
    expect(SSHPM::VERSION).not_to be nil
  end

  context "Docker test servers" do
    before :all do
      platforms = ['ubuntu-1604']

      @test_servers = platforms.map do |platform|
        container = Docker::Container.create(
          'Image' => "sshpm-test-server:#{platform}",
          'ExposedPorts' => { '22/tcp' => {} },
          'HostConfig' => {
            'PortBindings' => { '22/tcp' => [{}] }
          }
        ).start

        port = container.json["NetworkSettings"]["Ports"]["22/tcp"].first["HostPort"]

        { container: container, port: port }
      end
    end

    after :all do
      @test_servers.each do |server|
        server[:container].delete(force: true)
      end
    end

    context "Login as root" do
      it "is successfull if password is correct" do
        @test_servers.each do |server|
          expect do
            Net::SSH.start('localhost', 'root', password: 'test_password', port: server[:port], non_interactive: true, paranoid: false)
          end.to_not raise_error
        end
      end

      it "is unsuccessfull if password is incorrect" do
        @test_servers.each do |server|
          expect do
            Net::SSH.start('localhost', 'root', password: 'test_passwrd', port: server[:port], non_interactive: true, paranoid: false)
          end.to raise_error(Net::SSH::AuthenticationFailed)
        end
      end
    end
  end
end
