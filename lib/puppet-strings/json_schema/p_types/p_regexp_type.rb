# frozen_string_literal: true

require_relative 'base'

module PuppetStrings::JsonSchema::PTypes
  class PRegexpType < Base
    def emit(type)
      if type.pattern
        {
          const: type.pattern,
        }
      else
        {
          type: 'string',
        }
      end
    end
  end
end
