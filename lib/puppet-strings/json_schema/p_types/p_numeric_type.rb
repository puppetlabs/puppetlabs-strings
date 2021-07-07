# frozen_string_literal: true

require_relative 'base'

module PuppetStrings::JsonSchema::PTypes
  class PNumericType < Base
    def emit(type)
      {
        type: 'number'
      }
    end
  end
end
