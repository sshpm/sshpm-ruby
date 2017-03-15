require "net/ssh"
require "sshpm/version"
require "sshpm/exceptions"
require "sshpm/types"
require "sshpm/manager"
require "sshpm/host"

module SSHPM

  # Runs tasks provided in a block ond the specified hosts.
  # These tasks can be `add_user`, `remove_user`, etc. It makes
  # use of {SSHPM::Manager} to evaluate the provided block.
  #
  # @param hosts [Array<SSHPM::Host>] the hosts that the tasks
  #              must be ran on
  # @see SSHPM::Manager
  def self.manage(hosts = [], &block)
    hosts = [hosts] unless hosts.is_a? Array
    hosts = hosts.map { |host| Host.new host }

    hosts.map do |host|
      manager = Manager.new(host)
      manager.instance_eval(&block)
      manager.run_tasks
    end
  end
end
