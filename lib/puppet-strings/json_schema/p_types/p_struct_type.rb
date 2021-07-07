# frozen_string_literal: true

require_relative 'base'

module PuppetStrings::JsonSchema::PTypes
  class PStructType < Base
    def emit(type)
      st = {
        type: 'object',
        properties: {},
        required: [],
        additionalProperties: false,
      }

      type.elements.each do |element|
        r = process_struct_element(element)
        st[:properties].merge!(r[:properties])
        st[:required].concat(r[:required])
      end

      st
    end

    def process_struct_element(element)
      key_type = element.key_type
      required = false

      key = if key_type.is_a?(Puppet::Pops::Types::POptionalType)
              key_type.type.size_type_or_value.to_sym
            else
              required = true
              key_type.size_type_or_value.to_sym
            end

      value = convert(element.value_type)

      {
        properties: {
          key => value,
        },
        required: required ? [key] : []
      }
    end
  end
end
