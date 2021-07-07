# frozen_string_literal: true

require_relative 'base'

module PuppetStrings::JsonSchema::PTypes
  class PHashType < Base
    def emit(type)
      st = { type: 'object' }

      unless type.value_type.class == Puppet::Pops::Types::PAnyType
        st[:additionalProperties] = convert(type.value_type)
      end
      size = type.size_type
      return st if size.nil?

      st[:minProperties] = size.from unless size.from.nil?
      st[:maxProperties] = size.to unless size.to.nil?
      st
    end
  end
end
