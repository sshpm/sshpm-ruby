require "spec_helper"

describe SSHPM do
  it "has a version number" do
    expect(SSHPM::VERSION).not_to be nil
  end

  SSHPM::Tests::Platforms::Docker.each do |platform|
    context "Docker test on #{platform[:name]}" do
      before :all do
        @container = SSHPM::Tests::run_docker_container platform[:image]
        @port = @container.json["NetworkSettings"]["Ports"]["22/tcp"].first["HostPort"]
      end

      after :all do
        @container.delete(force: true)
      end

      context "Login as root" do
        it "is successfull if password is correct" do
          expect do
            opts = {
              password: 'test_password',
              port: @port,
              non_interactive: true,
              paranoid: false
            }

            Net::SSH.start('localhost', 'root', opts)
          end.to_not raise_error
        end

        it "is unsuccessfull if password is incorrect" do
          expect do
            opts = {
              password: 'test_passwrd',
              port: @port,
              non_interactive: true,
              paranoid: false
            }

            Net::SSH.start('localhost', 'root', opts)
          end.to raise_error(Net::SSH::AuthenticationFailed)
        end
      end

      context "Add a new user" do
        context "with only password" do
          before :all do
            @user = user = {
              username: Faker::Internet.user_name,
              password: Faker::Internet.password
            }

            @host = {
              hostname: 'localhost',
              port: @port, 
              user: 'root',
              password: 'test_password'
            }

            SSHPM.manage(@host) do
              add_user do
                name user[:username]
                password user[:password]
              end
            end
          end

          it "login successfully as the new user on all test servers" do
            expect do
              opts = {
                password: @user[:password],
                port: @port,
                non_interactive: true,
                paranoid: false
              }

              Net::SSH.start('localhost', @user[:username], opts)
            end.to_not raise_error
          end

          it "login fails if password is wrong" do
            expect do
              opts = {
                password: Faker::Internet.password,
                port: @port,
                non_interactive: true,
                paranoid: false
              }
              
              Net::SSH.start('localhost', @user[:username], opts)
            end.to raise_error(Net::SSH::AuthenticationFailed)
          end
        end

        context "with only pub/private keys" do
          before :all do
            @rsa_key = SSHKey.generate
            @user = user = {
              username: Faker::Internet.user_name,
              public_key: @rsa_key.ssh_public_key
            }

            @host = {
              hostname: 'localhost',
              port: @port, 
              user: 'root',
              password: 'test_password'
            }

            SSHPM.manage(@host) do
              add_user do
                name user[:username]
                public_key user[:public_key]
              end
            end
          end

          it "login successfully as the new user on all test servers" do
            expect do
              opts = {
                keys: [],
                key_data: [@rsa_key.private_key],
                keys_only: true,
                port: @port,
                non_interactive: true,
                paranoid: false
              }

              Net::SSH.start('localhost', @user[:username], opts)
            end.to_not raise_error
          end

          it "login fails if private_key is wrong" do
            expect do
              opts = {
                keys: [],
                key_data: [SSHKey.generate.private_key],
                keys_only: true,
                port: @port,
                non_interactive: true,
                paranoid: false
              }

              Net::SSH.start('localhost', @user[:username], opts)
            end.to raise_error(Net::SSH::AuthenticationFailed)
          end
        end

        context "with sudo access and password only" do
          before :all do
            @user = user ={
              username: Faker::Internet.user_name,
              password: Faker::Internet.password,
              sudo: true
            }
            @host = {
              hostname: 'localhost',
              port: @port,
              user: 'root',
              password: 'test_password'
            }

            SSHPM.manage(@host) do
              add_user do
                name user[:username]
                password user[:password]
                sudo user[:sudo]
              end 
            end
          end

          it "user can use sudo on all test servers" do
                opts = {
                  password: @user[:password],
                  port: @port,
                  paranoid: false
                }
                
                Net::SSH.start('localhost', @user[:username], opts) do |ssh|

                  output = ssh.exec!("echo #{@user[:password]} | sudo -kS --prompt=\"\" ls > /dev/null")
                  expect(output).to be_empty

                end
             
          end


       end

        context "with no sudo access and password only" do
          before :all do
            @user = user ={
              username: Faker::Internet.user_name,
              password: Faker::Internet.password,
              sudo: false
            }
            @host = {
              hostname: 'localhost',
              port: @port,
              user: 'root',
              password: 'test_password'
            }

            SSHPM.manage(@host) do
              add_user do
                name user[:username]
                password user[:password]
                sudo user[:sudo]
              end
            end
          end

          it "user cannot use sudo on all test servers" do
                opts = {
                  password: @user[:password],
                  port: @port,
                  paranoid: false
                }
                
                Net::SSH.start('localhost', @user[:username], opts) do |ssh|
                  
                  output = ssh.exec!("echo #{@user[:password]} | sudo -kS --prompt=\"\" ls > /dev/null")
                  expect(output).to_not be_empty

                end
          
          end
        

       end

       context "with sudo access and only pub/private keys" do
          before :all do
            @rsa_key = SSHKey.generate
            @user = user = {
              username: Faker::Internet.user_name,
              public_key: @rsa_key.ssh_public_key,
              sudo: true
            }

            @host = {
              hostname: 'localhost',
              port: @port, 
              user: 'root',
              password: 'test_password'
            }

            SSHPM.manage(@host) do
              add_user do
                name user[:username]
                public_key user[:public_key]
              end
            end
          end

          it "user can use sudo on all test servers" do
                opts = {
                  password: @user[:password],
                  port: @port,
                  paranoid: false
                }
                
                Net::SSH.start('localhost', @user[:username], opts) do |ssh|

                  output = ssh.exec!("echo #{@user[:password]} | sudo -kS --prompt=\"\" ls > /dev/null")
                  expect(output).to be_empty

                end
             
          end

        end

        context "with no sudo access and only pub/private keys" do
          before :all do
            @rsa_key = SSHKey.generate
            @user = user = {
              username: Faker::Internet.user_name,
              public_key: @rsa_key.ssh_public_key,
              sudo: false
            }

            @host = {
              hostname: 'localhost',
              port: @port, 
              user: 'root',
              password: 'test_password'
            }

            SSHPM.manage(@host) do
              add_user do
                name user[:username]
                public_key user[:public_key]
              end
            end
          end

          it "user cannot use sudo on all test servers" do
                opts = {
                  password: @user[:password],
                  port: @port,
                  paranoid: false
                }
                
                Net::SSH.start('localhost', @user[:username], opts) do |ssh|
                  
                  output = ssh.exec!("echo #{@user[:password]} | sudo -kS --prompt=\"\" ls > /dev/null")
                  expect(output).to_not be_empty

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

            @host = {
              hostname: 'localhost',
              port: @port,
              user: 'root',
              password: 'test_password'
            }

            SSHPM.manage(@host) do
              add_user do
                name user[:username]
                password user[:password]
                public_key user[:public_key]
              end
            end
          end
          
          context "login successfully as the new user on all test servers" do
            it "using identity file" do
              expect do
                opts = {
                  keys: [],
                  key_data: [@rsa_key.private_key],
                  keys_only: true,
                  port: @port,
                  non_interactive: true,
                  paranoid: false
                }

                Net::SSH.start('localhost', @user[:username], opts)
              end.to_not raise_error
            end

            it "using password" do
              expect do
                opts = {
                  password: @user[:password],
                  port: @port,
                  non_interactive: true,
                  paranoid: false
                }

                Net::SSH.start('localhost', @user[:username], opts)
              end.to_not raise_error
            end
          end

          context "login fails if password or private key is wrong" do
            it "using identity file" do
              expect do
                opts = {
                  keys: [],
                  key_data: [SSHKey.generate.private_key],
                  keys_only: true,
                  port: @port,
                  non_interactive: true,
                  paranoid: false
                }

                Net::SSH.start('localhost', @user[:username], opts)
              end.to raise_error(Net::SSH::AuthenticationFailed)
            end

            it "using password" do
              expect do
                opts = {
                  password: Faker::Internet.password,
                  port: @port,
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
