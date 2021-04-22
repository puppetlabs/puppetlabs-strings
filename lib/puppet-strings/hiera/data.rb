# frozen_string_literal: true

module PuppetStrings::Hiera
  class Data
    attr_reader :config_path, :data_paths

    def initialize(config_path)
      @config_path = config_path
      @data_paths = []

      load_config
    end

    def files
      @files ||= begin
                   result = {}

                   data_paths.each do |dp|
                     dp.matches.each do |file, interpolations|
                       unless result.key?(file)
                         result[file] = interpolations
                       end
                     end
                   end

                   result
                 end
    end

    # @return [Hash[String, Hash[String, Any]]]
    #   Full variable (class::var) -> filename: value
    def overrides
      @overrides ||= begin
                       overrides = {}

                       files.each_key do |file|
                         data = YAML.load(File.read(file))
                         data.each do |key, value|
                           overrides[key] ||= {}
                           overrides[key][file] = value
                         end
                       end

                       overrides
                     end
    end

    # @return [Hash[String, Hash[String, Any]]]
    #   variable -> filename: value
    def for_class(class_name)
      result = {}
      overrides.each do |key, value|
        override_class_name, _, variable = key.rpartition('::')
        if override_class_name == class_name
          result[variable] = value
        end
      end
      result
    end

    def to_s
      config_path
    end

    private

    def load_config
      return unless File.exist?(config_path)

      config = YAML.load(File.read(config_path))

      unless config['version'] == 5
        raise "Unsupported version '#{config['version']}'"
      end

      hierarchy = config['hierarchy']
      return unless hierarchy

      hierarchy.each do |level|
        data_hash = level['data_hash'] || config['defaults']['data_hash']
        next unless data_hash == 'yaml_data'

        datadir = level['datadir'] || config['defaults']['datadir']

        if level['path']
          data_paths << PuppetStrings::Hiera::HierarchyDataPath.new(datadir, level['path'])
        elsif level['paths']
          level['paths'].each do |path|
            data_paths << PuppetStrings::Hiera::HierarchyDataPath.new(datadir, path)
          end
        end
      end
    end
  end
end
