require "net/ssh"
require "sshpm/version"
require "sshpm/types"
require "sshpm/manager"
require "sshpm/entities"

module SSHPM
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
