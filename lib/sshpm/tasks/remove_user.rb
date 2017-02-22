module SSHPM::Tasks
  class RemoveUser < Dry::Struct
    constructor_type :strict_with_defaults

    attribute :name, Types::Strict::String
    attribute :delete_home, Types::Strict::Bool.default(false)

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
        flags = ""
        flags = flags + " -r " if delete_home

        ssh.exec! "userdel #{flags} #{name}"
      end
    end
  end
end
