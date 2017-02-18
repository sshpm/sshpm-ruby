require "sshpm/version"
require "sshpm/manager"

module SSHPM
  def self.manage(hosts = [], &block)
    hosts = [hosts] unless hosts.is_a? Array

    unless hosts.all? { |host| [String, Symbol].include? host.class }
      raise TypeError('hosts must be either String or Symbols')
    end

    hosts.map(&:to_s).uniq.map do |host|
      manager = Manager.new(host)
      manager.instance_eval(&block)
    end
  end
end
