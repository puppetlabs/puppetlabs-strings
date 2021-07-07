# frozen_string_literal: true

require_relative 'base'

module PuppetStrings::JsonSchema::PTypes
  class PCollectionType < Base
    def emit(type)
      {
        anyOf: [
          {
            type: 'object',
          },
          {
            type: 'array',
          },
        ]
      }
    end
  end
end
