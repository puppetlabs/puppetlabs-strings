# frozen_string_literal: true

require_relative 'base'

module PuppetStrings::JsonSchema::PTypes
  class PDefaultType < Base
    def emit(type)
      # The default type is not representable in Hiera:
      {}
    end
  end
end
