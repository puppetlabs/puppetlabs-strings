# frozen_string_literal: true

require_relative 'base'

module PuppetStrings::JsonSchema::PTypes
  class PTypeReferenceType < Base
    def emit(type)
      {
        :$ref => "#/data_type_aliases/#{type.type_string.downcase}"
      }
    end
  end
end
