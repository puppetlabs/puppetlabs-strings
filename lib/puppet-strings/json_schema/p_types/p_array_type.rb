# frozen_string_literal: true

require_relative 'base'

module PuppetStrings::JsonSchema::PTypes
  class PArrayType < Base
    def emit(type)
      st = {
        type: 'array',
      }

      unless type.element_type.class == Puppet::Pops::Types::PAnyType
        st[:items] = convert(type.element_type)
      end
      size = type.size_type
      return st if size.nil?

      st[:minItems] = size.from unless size.from.nil?
      st[:maxItems] = size.to unless size.to.nil?
      st
    end
  end
end
