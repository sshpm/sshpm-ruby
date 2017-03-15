module SSHPM
  module Tasks
    # Parent of all tasks, which defines a default {#run_on} method
    # with common function guards among all tasks
    class BaseTask < Dry::Struct

      # Runs the task on the provided host. The task is run through
      # a series of bash commands executed on the host through SSH.
      # Each task has a different set of commands, especialized for
      # its own purposes.
      #
      # @param host [SSHPM::Host]
      def run_on(host)
        if not host.is_a? SSHPM::Host
          raise TypeError("host #{host} is not a #{SSHPM::Host}")
        end
      end

      # Creates ssh options to be used in Net::SSH#start according
      # to the given host attributes
      #
      # @param host [SSHPM::Hots]
      # @return [Hash] options attribute
      def ssh_options(host)
        if not host.is_a? SSHPM::Host
          raise TypeError("host #{host} is not a #{SSHPM::Host}")
        end

        options = host.password.fmap do |password|
          { password: password, port: host.port, paranoid: false }
        end

        options = options || host.identity.fmap do |identity|
          {
            keys: [],
            key_data: [identity],
            keys_only: true,
            non_interactive: true,
            paranoid: false
          }
        end

        options.value
      end
    end
  end
end
