# frozen_string_literal: true

require_relative 'base'

module PuppetStrings::JsonSchema::PTypes
  class PStringType < Base
    def emit(type)
      min = nil
      max = nil

      if (sizetype = type.size_type)
        min = sizetype.from
        max = sizetype.to
      end

      st = { type: 'string' }
      st[:minLength] = min unless min.nil?
      st[:maxLength] = max unless max.nil?
      st
    end
  end
end
