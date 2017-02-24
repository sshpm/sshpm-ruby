module SSHPM::Tasks
  class AddUser < BaseTask
    constructor_type :strict_with_defaults

    attribute :name, Types::Strict::String
    attribute :password, Types::Maybe::Strict::String
    attribute :public_key, Types::Maybe::Strict::String
    attribute :sudo, Types::Strict::Bool.default(false)

    def initialize(h)
      super
      if password.none? and public_key.none?
        raise SSHPM::NoAuthenticationMethodDefined
      end
    end

    def run_on(host)
      super

      options = {
        password: host.password,
        port: host.port,
        paranoid: false
      }

      Net::SSH.start(host.hostname, host.user, options) do |ssh|
        ssh.exec! "useradd -m #{name}"

        password.bind do |password|
          ssh.exec! "echo \"#{name}:#{password}\" | chpasswd"
        end

        public_key.bind do |public_key|
          ssh_dir = "/home/#{name}/.ssh"
          auth_keys_file = "#{ssh_dir}/authorized_keys"

          ssh.exec! "mkdir -p #{ssh_dir}"
          ssh.exec! "chmod 700 #{ssh_dir}"
          ssh.exec! "echo \"#{public_key}\" >> #{auth_keys_file}"
          ssh.exec! "chmod 600 #{auth_keys_file}"
          ssh.exec! "chown -R #{name}:#{name} #{ssh_dir}"
        end
      end
    end
  end
end
