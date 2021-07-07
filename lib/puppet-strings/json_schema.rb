# frozen_string_literal: true

require 'json'
require 'deep_merge'
require 'puppet_pal'

require_relative 'json_schema/p_types'

# The module for JSON related functionality.
module PuppetStrings::JsonSchema
  # Renders the current YARD registry pertinent to Lookup data as
  # [JSON Schema](https://json-schema.org/) format to the given file
  # (or STDOUT if nil).
  #
  # @param [String] file The path to the output file to render the registry to. If nil, output will be to STDOUT.
  # @return [void]
  def self.render(file = nil, code_string: nil)
    document = {
      :$schema => 'https://json-schema.org/draft/2020-12/schema#',
      type: 'object',
      additionalProperties: true,
    }

    type_aliases = {}
    YARD::Registry.all(:puppet_data_type_alias).sort_by!(&:name).each do |data_type_alias|
      type_aliases.merge!(data_type_alias.to_schema)
    end

    properties = {}
    YARD::Registry.all(:puppet_class).sort_by!(&:name).each do |cls|
      properties.merge!(cls.to_schema)
    end

    ptypes = PuppetStrings::JsonSchema::PTypes

    ptypes.puppet_compiler(code_string: code_string) do |compiler|
      properties.each do |name, prop|
        next unless prop.key?(:_puppet_type)

        parsed_type = prop.delete(:_puppet_type)
        puppet_type = compiler.type(parsed_type)
        schema_type = ptypes.ptype_to_schema(puppet_type)
        prop.merge!(schema_type)
      end

      type_aliases.each do |name, prop|
        next unless prop.key?(:_puppet_type)

        parsed_type = prop.delete(:_puppet_type)
        puppet_type = compiler.type(parsed_type)
        schema_type = ptypes.ptype_to_schema(puppet_type)
        prop.deep_merge!(schema_type)
      end
    end

    document[:properties] = properties
    document[:data_type_aliases] = type_aliases

    if file
      File.open(file, 'w') do |f|
        f.write(JSON.pretty_generate(document))
        f.write("\n")
      end
    else
      puts JSON.pretty_generate(document)
    end
  end
end
