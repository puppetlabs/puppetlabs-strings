# frozen_string_literal: true

require_relative 'base'

module PuppetStrings::JsonSchema::PTypes
  class PScalarType < Base
    def emit(type)
      {
        anyOf: [
          {
            type: 'number',
          },
          {
            type: 'string',
          },
          {
            type: 'boolean',
          },
        ]
      }
    end
  end

  class PScalarDataType < PScalarType
  end
end
