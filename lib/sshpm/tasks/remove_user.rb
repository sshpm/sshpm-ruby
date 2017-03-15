module SSHPM
  module Tasks
    # Contains data and commands necessary to remove a user user from a host
    # over SSH.
    class RemoveUser < BaseTask
      constructor_type :strict_with_defaults

      # @return [String] username of the user to be removed
      attribute :name, Types::Strict::String
      # @return [Bool] true if home dir should be removed, and false otherwise
      attribute :delete_home, Types::Strict::Bool.default(false)

      # Runs the task on the provided host. The task is run through
      # a series of bash commands executed on the host through SSH.
      # Each task has a different set of commands, especialized for
      # its own purposes.
      #
      # For this specific task, the purpose is to remove an existing
      # user from the host.
      #
      # @param host [SSHPM::Host]
      def run_on(host)
        super

        Net::SSH.start(host.hostname, host.user, ssh_options(host)) do |ssh|
          flags = ""
          flags = flags + " -r " if delete_home

          ssh.exec! "userdel #{flags} #{name}"
        end
      end
    end
  end
end
