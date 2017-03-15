module SSHPM::Tasks
  class AddUser < Dry::Struct
    constructor_type :strict_with_defaults

    attribute :name, Types::Strict::String
    attribute :password, Types::Strict::String.default("")
    attribute :public_key, Types::Strict::String.default("")
    attribute :sudo, Types::Strict::Bool.default(false)

    def run_on(host)
      unless host.is_a? SSHPM::Host
        raise TypeError("host #{host} is not a #{SSHPM::Host}")
      end

      options = {
        password: host.password,
        port: host.port,
        paranoid: false
      }

      Net::SSH.start(host.hostname, host.user, options) do |ssh|
        ssh.exec! "useradd -m #{name}"

        if password != ""
          ssh.exec! "echo \"#{name}:#{password}\" | chpasswd"
        end

        if public_key != ""
          ssh_dir = "/home/#{name}/.ssh"
          auth_keys_file = "#{ssh_dir}/authorized_keys"

          ssh.exec! "mkdir -p #{ssh_dir}"
          ssh.exec! "chmod 700 #{ssh_dir}"
          ssh.exec! "echo \"#{public_key}\" >> #{auth_keys_file}"
          ssh.exec! "chmod 600 #{auth_keys_file}"
          ssh.exec! "chown -R #{name}:#{name} #{ssh_dir}"
        end

        if sudo 
          ssh.exec! "echo \"#{name} ALL=(ALL) NOPASSWD:ALL\" >> /etc/sudoers"
        end


      end
    end
  end
end
