module SSHPM::Tasks
  # Contains data and commands necessary to add a new user to a host
  # over SSH.
  class AddUser < BaseTask
    constructor_type :strict_with_defaults

    # @return [String] username of the user to be added
    attribute :name, Types::Strict::String
    # @return [Maybe(String)] password of the user to be added
    attribute :password, Types::Maybe::Strict::String
    # @return [Maybe(String)] public_key of the user to be added
    attribute :public_key, Types::Maybe::Strict::String
    # @return [Bool] true if the user must have sudo acces, and false otherwise
    attribute :sudo, Types::Strict::Bool.default(false)

    def initialize(h)
      super
      if password.none? and public_key.none?
        raise SSHPM::NoAuthenticationMethodDefined
      end
    end

    # Runs the task on the provided host. The task is run through
    # a series of bash commands executed on the host through SSH.
    # Each task has a different set of commands, especialized for
    # its own purposes.
    #
    # For this specific task, the purpose is to add a new user to
    # the host.
    #
    # @param host [SSHPM::Host]
    def run_on(host)
      super

      Net::SSH.start(host.hostname, host.user, ssh_options(host)) do |ssh|
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

        if sudo 
          ssh.exec! "echo \"#{name} ALL=(ALL) NOPASSWD:ALL\" >> /etc/sudoers"
        end


      end
    end
  end
end
