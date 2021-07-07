# frozen_string_literal: true

require_relative 'base'

module PuppetStrings::JsonSchema::PTypes
  class PTimestampType < Base
    def emit(type)
      {
        anyOf: [
          {
            type: 'string',
            format: 'date-time',
          },
          {
            type: 'string',
            format: 'date',
          },
        ],
      }
    end
  end
end
