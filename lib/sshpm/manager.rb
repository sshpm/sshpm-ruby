require 'sshpm/tasks'

module SSHPM

  # Main interface for the host management DSL, this class methods
  # {#add_user}, {#remove_user} builds {SSHPM::Tasks::BaseTask Tasks} 
  # and {#run_tasks} triggers them by calling their 
  # {SSHPM::Tasks::BaseTask#run_on} method
  #
  # @see SSHPM::Tasks::BaseTask
  # @see SSHPM::Tasks::Builder
  class Manager
    attr_accessor :host, :tasks

    # Takes a host to and initializes `task` attribute as an empty
    # array.
    #
    # @param [SSHPM::Host] host to be managed
    # @see SSHPM::Host
    def initialize(host=nil)
      @host = host
      @tasks = []
    end

    # Triggers all tasks added to this class through {#add_user} and 
    # {#remove_user} by calling {SSHPM::Tasks::BaseTask#run_on}
    #
    # @see SSHPM::Tasks::BaseTask#run_on
    def run_tasks
      tasks.map do |task|
        task.run_on(@host)
      end
    end

    # Forwards a given block to {SSHPM::Tasks::Builder} by using
    # #instance_eval, and with the built attributes, constructs
    # a {SSHPM::Tasks::AddUser} and adds it to `tasks` array attribute
    #
    # @return [Array<SSHPM::Tasks::BaseTask>] @tasks attribute
    # @raise [SSHPM::NoAuthenticationMethodDefined] if neither password
    #        or publick_key are specified in the given block
    def add_user(&block)
      task_builder = SSHPM::Tasks::Builder.build(&block)
      tasks << SSHPM::Tasks::AddUser.new(task_builder.attributes)
    end

    # Forwards a given block to {SSHPM::Tasks::Builder} by using
    # #instance_eval, and with the built attributes, constructs
    # a {SSHPM::Tasks::RemoveUser} and adds it to `tasks` array attribute
    #
    # @return [Array<SSHPM::Tasks::BaseTask>] @tasks attribute
    def remove_user(&block)
      task_builder = SSHPM::Tasks::Builder.build(&block)
      tasks << SSHPM::Tasks::RemoveUser.new(task_builder.attributes)
    end
  end
end
