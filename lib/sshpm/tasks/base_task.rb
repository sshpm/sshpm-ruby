module SSHPM
  module Tasks
    class BaseTask < Dry::Struct
      def run_on(host)
        if not host.is_a? SSHPM::Host
          raise TypeError("host #{host} is not a #{SSHPM::Host}")
        end
      end
    end
  end
end
