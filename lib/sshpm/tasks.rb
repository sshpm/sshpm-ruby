require 'dry-struct'
require 'sshpm/tasks/builder'

module Types
  include Dry::Types.module
end

module SSHPM::Tasks
  class AddUser < Dry::Struct
    constructor_type :strict_with_defaults

    attribute :name, Types::Strict::String
    attribute :public_key, Types::Strict::String
    attribute :sudo, Types::Strict::Bool.default(false)
  end

  class RemoveUser < Dry::Struct
    attribute :name, Types::Strict::String
  end
end
