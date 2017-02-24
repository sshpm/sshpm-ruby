require 'dry-struct'

Dry::Types.load_extensions :maybe

module Types
  include Dry::Types.module
end
