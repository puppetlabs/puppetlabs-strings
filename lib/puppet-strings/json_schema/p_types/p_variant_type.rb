# frozen_string_literal: true

require_relative 'base'

module PuppetStrings::JsonSchema::PTypes
  class PVariantType < Base
    def emit(type)
      any_of(type.types.map { |t| convert(t) })
    end
  end
end
