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

    context "Add a new user" do
      before :all do
        @user = user = {
          username: Faker::Internet.user_name,
          password: Faker::Internet.password
        }

        @hosts = @test_servers.map do |server|
          {
            hostname: 'localhost',
            port: server[:port], 
            user: 'root',
            password: 'test_password'
          }
        end

        SSHPM.manage(@hosts) do
          add_user do
            name user[:username]
            password user[:password]
          end
        end
      end

      it "login successfully as the new user on all test servers" do
        @test_servers.each do |server|
          expect do
            Net::SSH.start('localhost', @user[:username], password: @user[:password], port: server[:port], non_interactive: true, paranoid: false)
          end.to_not raise_error
        end
      end
    end
  end
end
