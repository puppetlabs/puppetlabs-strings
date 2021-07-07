# frozen_string_literal: true

require_relative 'base'

module PuppetStrings::JsonSchema::PTypes
  class PBooleanType < Base
    def emit(type)
      {
        type: 'boolean'
      }
    end
  end
end
