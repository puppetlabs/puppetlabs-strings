# frozen_string_literal: true

require_relative 'base'

module PuppetStrings::JsonSchema::PTypes
  class PAnyType < Base
    def emit(type)
      {}
    end
  end
end
