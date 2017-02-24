module SSHPM
  module Tasks
    # A helper entity whose intent is to provide and idiom to task
    # creation DSL
    class Builder
      def initialize
        @attributes = {}
      end

      attr_reader :attributes

      def method_missing(name, *args)
        attributes[name] = args[0]
      end

      def self.build(&block)
        builder = Builder.new
        builder.instance_eval(&block) unless block.nil?
        builder
      end
    end
  end
end
