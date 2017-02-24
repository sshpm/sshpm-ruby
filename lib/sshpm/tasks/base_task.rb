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
    end
  end
end
