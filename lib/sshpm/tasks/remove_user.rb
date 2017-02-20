module SSHPM::Tasks
  class RemoveUser < Dry::Struct
    attribute :name, Types::Strict::String
  end
end
