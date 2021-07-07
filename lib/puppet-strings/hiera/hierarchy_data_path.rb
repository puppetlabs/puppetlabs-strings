# frozen_string_literal: true

module PuppetStrings::Hiera
  class HierarchyDataPath
    attr_reader :datadir, :path, :regex, :mapping

    def initialize(datadir, path)
      @datadir = datadir
      @path = path
      @regex, @mapping = HierarchyDataPath.path2regex(path)
    end

    def matches
      result = {}

      Dir.chdir(datadir) do
        Dir['**'].each do |entry|
          next unless File.file?(entry)

          regex.match(entry) do |match|
            full_path = File.join(datadir, entry)
            interpolations = {}

            mapping.each do |name, interpolation|
              interpolations[interpolation] = match.named_captures[name]
            end

            result[full_path] = interpolations
          end
        end
      end

      result
    end

    def self.path2regex(path)
      mapping = {}

      intermediate_result = path

      # First pass - intermediate replacements
      path.scan(/%{[^}]+}/).each_with_index do |interpolation, i|
        replacement = "X_INTERPOLATION_#{i}_X"
        mapping[replacement] = interpolation[2..-2]
        intermediate_result = intermediate_result.sub(interpolation, replacement)
      end

      # Second pass - escape any special chars
      escaped = Regexp.escape(intermediate_result)

      # Third pass - replacement intermediates with regex
      mapping.each_key do |replacement|
        escaped = escaped.sub(replacement, "(?<#{replacement}>.+)")
      end

      [Regexp.new(escaped), mapping]
    end

    def to_s
      File.join(datadir, path)
    end
  end
end
