# frozen_string_literal: true

require 'puppet_pal'

module PuppetStrings::JsonSchema
  require_relative 'p_types/base'
  require_relative 'p_types/p_any_type'
  require_relative 'p_types/p_array_type'
  require_relative 'p_types/p_boolean_type'
  require_relative 'p_types/p_collection_type'
  require_relative 'p_types/p_default_type'
  require_relative 'p_types/p_enum_type'
  require_relative 'p_types/p_float_type'
  require_relative 'p_types/p_hash_type'
  require_relative 'p_types/p_integer_type'
  require_relative 'p_types/p_notundef_type'
  require_relative 'p_types/p_numeric_type'
  require_relative 'p_types/p_optional_type'
  require_relative 'p_types/p_pattern_type'
  require_relative 'p_types/p_regexp_type'
  require_relative 'p_types/p_scalar_type'
  require_relative 'p_types/p_string_type'
  require_relative 'p_types/p_struct_type'
  require_relative 'p_types/p_timestamp_type'
  require_relative 'p_types/p_type_alias_type'
  require_relative 'p_types/p_type_reference_type'
  require_relative 'p_types/p_tuple_type'
  require_relative 'p_types/p_undef_type'
  require_relative 'p_types/p_variant_type'

  module PTypes
    def self.ptype_to_schema(puppet_type)
      ptype = PuppetStrings::JsonSchema::PTypes::Base.new()
      ptype.convert(puppet_type)
    end

    def self.valid_environment?
      # Use the environment / environmentpath available as a result of running
      # as a Puppet Face to provide a compiler environment which can resolve
      # data type aliases for that environment:
      @valid_env ||= Puppet::Pal.in_environment(
        Puppet[:environment],
        envpath: Puppet[:environmentpath],
        facts: {}
      ) { |pal| proc {} }
    rescue ArgumentError
      false
    rescue Puppet::Settings::InterpolationError
      false
    else
      true
    end

    def self.puppet_compiler(code_string: nil)
      if valid_environment?
        Puppet::Pal.in_environment(
          Puppet[:environment],
          envpath: Puppet[:environmentpath],
          facts: {},
        ) do |pal|
          pal.with_catalog_compiler(code_string: code_string) do |compiler|
            yield compiler
          end
        end
      else
        Puppet::Pal.in_tmp_environment('puppet_strings', facts: {}) do |pal|
          pal.with_catalog_compiler(code_string: code_string) do |compiler|
            yield compiler
          end
        end
      end
    end
  end
end
