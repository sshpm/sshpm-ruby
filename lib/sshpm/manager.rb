require 'sshpm/tasks'

module SSHPM
  class Manager
    attr_accessor :host, :tasks

    def initialize(host=nil)
      @host = host
      @tasks = []
    end

    def run_tasks
      tasks.map do |task|
        task.run_on(@host)
      end
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
end
