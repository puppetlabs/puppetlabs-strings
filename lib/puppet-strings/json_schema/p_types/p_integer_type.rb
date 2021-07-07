# frozen_string_literal: true

require_relative 'base'

module PuppetStrings::JsonSchema::PTypes
  class PIntegerType < PFloatType
    def emit(type)
      st = super(type)
      st[:type] = 'integer'
      st
    end
  end
end
