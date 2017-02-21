require 'dry-struct'

module Types
  include Dry::Types.module
end

module SSHPM
  class Host < Dry::Struct
    constructor_type :strict_with_defaults

    attribute :hostname, Types::Strict::String
    attribute :port, Types::Strict::String
    attribute :user, Types::Strict::String.default('root')
    attribute :password, Types::Strict::String.default("")
    attribute :identity, Types::Strict::String.default("")
  end
end
