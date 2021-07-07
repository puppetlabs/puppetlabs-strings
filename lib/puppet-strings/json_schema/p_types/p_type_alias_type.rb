# frozen_string_literal: true

require_relative 'base'

module PuppetStrings::JsonSchema::PTypes
  class PTypeAliasType < Base
    def emit(type)
      {
        :$ref => "#/data_type_aliases/#{type.name.downcase}"
      }
    end
  end
end
