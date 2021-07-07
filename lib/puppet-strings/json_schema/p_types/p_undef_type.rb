# frozen_string_literal: true

require_relative 'base'

module PuppetStrings::JsonSchema::PTypes
  class PUndefType < Base
    def emit(type)
      {
        type: 'null'
      }
    end
  end
end
