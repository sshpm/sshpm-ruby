module SSHPM::Tasks
  class SSHPM::Tasks::Builder
    def initialize
      @attributes = {}
    end

    attr_reader :attributes

    def method_missing(name, *args)
      attributes[name] = args[0]
    end
  end
end
