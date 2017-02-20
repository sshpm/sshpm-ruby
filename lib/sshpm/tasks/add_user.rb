module SSHPM::Tasks
  class AddUser < Dry::Struct
    constructor_type :strict_with_defaults

    attribute :name, Types::Strict::String
    attribute :password, Types::Strict::String
    attribute :sudo, Types::Strict::Bool.default(false)

    def run_on(host)
      unless host.is_a? SSHPM::Host
        raise TypeError("host #{host} is not a #{SSHPM::Host}")
      end

      options = { password: host.password, port: host.port }
      Net::SSH.start(host.hostname, host.user, options) do |ssh|
        ssh.exec! "useradd -m #{name}"
        ssh.exec! "echo \"#{name}:#{password}\" | chpasswd"
      end
    end
  end
end
