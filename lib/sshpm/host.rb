require 'dry-struct'

module SSHPM
  # Keeps data for a manageable host and perform type validations
  # on the attributes
  class Host < Dry::Struct
    constructor_type :strict_with_defaults

    # @return [String] the hostname of the host, like an IP address or domain
    attribute :hostname, Types::Strict::String
    # @return [String] the port in which the SSH server is listening
    #         to in the host
    attribute :port, Types::Strict::String
    # @return [String] the username that can be used to SSH into the host
    attribute :user, Types::Strict::String.default('root')
    # @return [String] the password that can be used to SSH into the host
    attribute :password, Types::Maybe::Strict::String
    # @return [String] the password that can be used to SSH into the host
    attribute :identity, Types::Maybe::Strict::String

    def initialize(h)
      super
      if password.none? and identity.none?
        raise SSHPM::NoAuthenticationMethodDefined
      end
    end
  end
end
