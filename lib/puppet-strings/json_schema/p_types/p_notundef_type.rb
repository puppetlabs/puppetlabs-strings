# frozen_string_literal: true

require_relative 'base'

module PuppetStrings::JsonSchema::PTypes
  class PNotUndefType < Base
    def emit(type)
      {
        not: {
          type: 'null'
        }
      }
    end
  end
end
