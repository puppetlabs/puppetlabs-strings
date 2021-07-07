# frozen_string_literal: true

require 'js_regex'

module PuppetStrings::JsonSchema::PTypes
  class PPatternType < Base
    def emit(type)
      if type.patterns.size > 1
        any_of(type.patterns.map { |r| emit_pattern(r) })
      else
        emit_pattern(type.patterns.first)
      end
    end

    private

    def emit_pattern(type)
      st = { type: 'string' }

      js = JsRegex.new(type.regexp)

      unless js.warnings.empty?
        st[:$comment] = "Unable to convert regex to Javascript type: #{js.warnings.join("\n")}"
        return st
      end

      st[:pattern] = js.source
      st
    end
  end
end
