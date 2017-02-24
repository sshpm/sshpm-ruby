module SSHPM::Tasks
  class RemoveUser < BaseTask
    constructor_type :strict_with_defaults

    attribute :name, Types::Strict::String
    attribute :delete_home, Types::Strict::Bool.default(false)

    def run_on(host)
      super

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
