require "spec_helper"
require "docker"
require "net/ssh"
require "sshkey"

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
            opts = {
              password: 'test_password',
              port: server[:port],
              non_interactive: true,
              paranoid: false
            }

            Net::SSH.start('localhost', 'root', opts)
          end.to_not raise_error
        end
      end

      it "is unsuccessfull if password is incorrect" do
        @test_servers.each do |server|
          expect do
            opts = {
              password: 'test_passwrd',
              port: server[:port],
              non_interactive: true,
              paranoid: false
            }

            Net::SSH.start('localhost', 'root', opts)
          end.to raise_error(Net::SSH::AuthenticationFailed)
        end
      end
    end

    context "Add a new user" do
      context "with only password" do
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
              opts = {
                password: @user[:password],
                port: server[:port],
                non_interactive: true,
                paranoid: false
              }
              
              Net::SSH.start('localhost', @user[:username], opts)
            end.to_not raise_error
          end
        end

        it "login fails if password is wrong" do
          @test_servers.each do |server|
            expect do
              opts = {
                password: Faker::Internet.password,
                port: server[:port],
                non_interactive: true,
                paranoid: false
              }
              
              Net::SSH.start('localhost', @user[:username], opts)
            end.to raise_error(Net::SSH::AuthenticationFailed)
          end
        end
      end

      context "with only pub/private keys" do
        before :all do
          @rsa_key = SSHKey.generate
          @user = user = {
            username: Faker::Internet.user_name,
            public_key: @rsa_key.ssh_public_key
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
              public_key user[:public_key]
            end
          end
        end

        it "login successfully as the new user on all test servers" do
          @test_servers.each do |server|
            expect do
              opts = {
                keys: [],
                key_data: [@rsa_key.private_key],
                keys_only: true,
                port: server[:port],
                non_interactive: true,
                paranoid: false
              }

              Net::SSH.start('localhost', @user[:username], opts)
            end.to_not raise_error
          end
        end

        it "login fails if private_key is wrong" do
          @test_servers.each do |server|
            expect do
              opts = {
                keys: [],
                key_data: [SSHKey.generate.private_key],
                keys_only: true,
                port: server[:port],
                non_interactive: true,
                paranoid: false
              }

              Net::SSH.start('localhost', @user[:username], opts)
            end.to raise_error(Net::SSH::AuthenticationFailed)
          end
        end
      end

      context "with both password and pub/private keys" do
        before :all do
          @rsa_key = SSHKey.generate
          @user = user = {
            username: Faker::Internet.user_name,
            password: Faker::Internet.password,
            public_key: @rsa_key.ssh_public_key
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
              public_key user[:public_key]
            end
          end
        end

        context "login successfully as the new user on all test servers" do
          it "using identity file" do
            @test_servers.each do |server|
              expect do
                opts = {
                  keys: [],
                  key_data: [@rsa_key.private_key],
                  keys_only: true,
                  port: server[:port],
                  non_interactive: true,
                  paranoid: false
                }

                Net::SSH.start('localhost', @user[:username], opts)
              end.to_not raise_error
            end
          end

          it "using password" do
            @test_servers.each do |server|
              expect do
                opts = {
                  password: @user[:password],
                  port: server[:port],
                  non_interactive: true,
                  paranoid: false
                }

                Net::SSH.start('localhost', @user[:username], opts)
              end.to_not raise_error
            end
          end
        end

        context "login fails if password or private key is wrong" do
          it "using identity file" do
            @test_servers.each do |server|
              expect do
                opts = {
                  keys: [],
                  key_data: [SSHKey.generate.private_key],
                  keys_only: true,
                  port: server[:port],
                  non_interactive: true,
                  paranoid: false
                }

                Net::SSH.start('localhost', @user[:username], opts)
              end.to raise_error(Net::SSH::AuthenticationFailed)
            end
          end

          it "using password" do
            @test_servers.each do |server|
              expect do
                opts = {
                  password: Faker::Internet.password,
                  port: server[:port],
                  non_interactive: true,
                  paranoid: false
                }

                Net::SSH.start('localhost', @user[:username], opts)
              end.to raise_error(Net::SSH::AuthenticationFailed)
            end
          end
        end
      end
    end
  end
end
