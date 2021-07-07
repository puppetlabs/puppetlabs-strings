# frozen_string_literal: true

require_relative 'base'

module PuppetStrings::JsonSchema::PTypes
  class PEnumType < Base
    def emit(type)
      {
        enum: type.values
      }
    end
  end
end
