# frozen_string_literal: true

require_relative 'base'

module PuppetStrings::JsonSchema::PTypes
  class PTupleType < Base
    def emit(type)
      st = {
        type: 'array',
        prefixItems: type.types.map { |t| convert(t) },
      }
      size = type.size_type

      st[:minItems] = size&.from || type.types.size
      st[:maxItems] = size&.to || type.types.size

      if size&.to && size.to > type.types.size
        st[:items] = st[:prefixItems].last
      end
      st
    end
  end
end
