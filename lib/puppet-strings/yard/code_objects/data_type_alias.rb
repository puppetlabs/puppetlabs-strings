# frozen_string_literal: true

require 'puppet-strings/yard/code_objects/group'
require 'puppet-strings/yard/util'

# Implements the group for Puppet DataTypeAliases.
class PuppetStrings::Yard::CodeObjects::DataTypeAliases < PuppetStrings::Yard::CodeObjects::Group
  # Gets the singleton instance of the group.
  # @return Returns the singleton instance of the group.
  def self.instance
    super(:puppet_data_type_aliases)
  end

  # Gets the display name of the group.
  # @param [Boolean] prefix whether to show a prefix. Ignored for Puppet group namespaces.
  # @return [String] Returns the display name of the group.
  def name(prefix = false)
    'Puppet Data Type Aliases'
  end
end

# Implements the Puppet DataTypeAlias code object.
class PuppetStrings::Yard::CodeObjects::DataTypeAlias < PuppetStrings::Yard::CodeObjects::Base
  attr_reader :statement
  attr_accessor :alias_of

  # Initializes a Puppet data type alias code object.
  # @param [PuppetStrings::Parsers::DataTypeAliasStatement] statement The data type alias statement that was parsed.
  # @return [void]
  def initialize(statement)
    @statement = statement
    @alias_of = statement.alias_of
    super(PuppetStrings::Yard::CodeObjects::DataTypeAliases.instance, statement.name)
  end

  # Gets the type of the code object.
  # @return Returns the type of the code object.
  def type
    :puppet_data_type_alias
  end

  # Gets the source of the code object.
  # @return Returns the source of the code object.
  def source
    # Not implemented, but would be nice!
    nil
  end

  # Converts the code object to a hash representation.
  # @return [Hash] Returns a hash representation of the code object.
  def to_hash
    hash = {}
    hash[:name] = name
    hash[:file] = file
    hash[:line] = line
    hash[:docstring] = PuppetStrings::Yard::Util.docstring_to_hash(docstring)
    hash[:alias_of] = alias_of
    hash
  end

  def to_schema
    summary_tags = tags.select { |t| t.tag_name == 'summary' }
    param_tags = tags.select { |t| t.tag_name == 'param' }

    if summary_tags.empty?
      title = name.to_s
    else
      title = summary_tags.first.text
    end

    doctext = (docstring || '').empty? ? title : (docstring || '')

    hash = {
      title: title,
      description: doctext.gsub("\n", ' '),
      markdownDescription: doctext,
      _puppet_type: alias_of,
      :$comment => alias_of,
    }

    props = {}
    param_tags.each do |tag|
      props[tag.name] = {
        description: tag.text,
        markdownDescription: tag.text,
      }
    end
    hash[:properties] = props unless props.empty?
    { name.downcase => hash }
  end
end
