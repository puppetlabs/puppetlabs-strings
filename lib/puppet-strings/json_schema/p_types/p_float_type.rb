# frozen_string_literal: true

require_relative 'base'

module PuppetStrings::JsonSchema::PTypes
  class PFloatType < Base
    def emit(type)
      st = { type: 'number' }
      st[:minimum] = type.from unless type.from.nil?
      st[:maximum] = type.to unless type.to.nil?
      st
    end
  end
end
