# frozen_string_literal: true

require_relative 'base'

module PuppetStrings::JsonSchema::PTypes
  class POptionalType < Base
    def emit(type)
      any_of(
        [
          { type: 'null' },
          convert(type.type),
        ]
      )
    end
  end
end
