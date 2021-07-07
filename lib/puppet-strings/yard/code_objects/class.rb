# frozen_string_literal: true

require 'puppet-strings/yard/code_objects/group'

# Implements the group for Puppet classes.
class PuppetStrings::Yard::CodeObjects::Classes < PuppetStrings::Yard::CodeObjects::Group
  # Gets the singleton instance of the group.
  # @return Returns the singleton instance of the group.
  def self.instance
    super(:puppet_classes)
  end

  # Gets the display name of the group.
  # @param [Boolean] prefix whether to show a prefix. Ignored for Puppet group namespaces.
  # @return [String] Returns the display name of the group.
  def name(prefix = false)
    'Puppet Classes'
  end
end

# Implements the Puppet class code object.
class PuppetStrings::Yard::CodeObjects::Class < PuppetStrings::Yard::CodeObjects::Base
  attr_reader :statement
  attr_reader :parameters

  # Initializes a Puppet class code object.
  # @param [PuppetStrings::Parsers::ClassStatement] statement The class statement that was parsed.
  # @return [void]
  def initialize(statement)
    @statement = statement
    @parameters = statement.parameters.map { |p| [p.name, p.value] }
    super(PuppetStrings::Yard::CodeObjects::Classes.instance, statement.name)
  end

  # Gets the type of the code object.
  # @return Returns the type of the code object.
  def type
    :puppet_class
  end

  # Gets the source of the code object.
  # @return Returns the source of the code object.
  def source
    @statement.source
  end

  # Converts the code object to a hash representation.
  # @return [Hash] Returns a hash representation of the code object.
  def to_hash
    hash = {}
    hash[:name] = name
    hash[:file] = file
    hash[:line] = line
    hash[:inherits] = statement.parent_class if statement.parent_class
    hash[:docstring] = PuppetStrings::Yard::Util.docstring_to_hash(docstring)
    defaults = Hash[*parameters.reject{ |p| p[1].nil? }.flatten]
    hash[:defaults] = defaults unless defaults.nil? || defaults.empty?
    hash[:source] = source unless source.nil? || source.empty?
    hash
  end

  def to_schema
    props = {}

    paramhash = Hash[parameters]

    tags.select { |t| t.tag_name == 'param' }.each do |tag|
      apl_name = "#{name}::#{tag.name}"

      if tag.types.nil? || tag.types.empty?
        type_text = '[Any]'
        type = 'Any'
      else
        type_text = "[#{tag.types.join(', ')}]"
        type = tag.types.first
      end

      def_str = if paramhash.key?(tag.name) && paramhash[tag.name] && ! paramhash[tag.name].empty?
                  "\nDefault: `#{paramhash[tag.name]}`"
                else
                  ''
                end

      md_desc = <<~"MD"
      `#{type_text}`

      #{tag.text.nil? || tag.text.empty? ? 'No documentation available.': tag.text}
      #{def_str}
      MD

      props[apl_name] = {
        markdownDescription: md_desc,
        :$comment => "Puppet Data type: #{type.inspect}",
        _puppet_type: type,
      }
      props[apl_name][:description] = tag.text.gsub("\n", ' ') unless tag.text.nil?
    end

    props
  end
end
