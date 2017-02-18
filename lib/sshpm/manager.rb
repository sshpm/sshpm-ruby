require 'sshpm/tasks'

class SSHPM::Manager
  attr_accessor :host, :tasks

  def initialize(host='localhost')
    @host = host
    @tasks = []
  end

  def add_user(&block)
    task_builder = SSHPM::Tasks::Builder.new
    task_builder.instance_eval(&block)
    tasks << SSHPM::Tasks::AddUser.new(task_builder.attributes)
  end

  def remove_user(&block)
    task_builder = SSHPM::Tasks::Builder.build(&block)
    tasks << SSHPM::Tasks::RemoveUser.new(task_builder.attributes)
  end
end
