# frozen_string_literal: true

require 'puppet-strings/markdown/base'

module PuppetStrings::Markdown
  class PuppetClass < Base
    def initialize(registry)
      @template = 'classes_and_defines.erb'
      super(registry, 'class')
    end

    def hiera_overrides
      @hiera_overrides ||= begin
                             hiera = PuppetStrings::Hiera.load_config
                             overrides = hiera.for_class(name)

                             result = {}

                             overrides.each do |variable, files|
                               result[variable] = files.map do |filename, value|
                                 interpolations = hiera.files[filename]
                                 [filename, interpolations, value]
                               end
                             end

                             result
                           end
    end

    def render
      super(@template)
    end
  end
end
