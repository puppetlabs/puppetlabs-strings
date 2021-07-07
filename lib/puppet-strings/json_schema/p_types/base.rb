# frozen_string_literal: true

module PuppetStrings::JsonSchema
  module PTypes
    class Base
      def convert(type)
        # PDataType is actually defined in terms of a data type alias. This
        # short cuts right to any value, which for JSON/YAML data is a good fit
        # for 'Data':
        return {} if type.name == 'Data'

        ptype = puppet_type(type)
        begin
          ptype_cls = Object.const_get("PuppetStrings::JsonSchema::PTypes::#{ptype}")
        rescue NameError
          {
            :$comment => "Conversion for Puppet type #{ptype} is not implemented yet"
          }
        else
          ptype_cls.new.emit(type)
        end
      end

      def emit
        raise 'Not implemented - you must implement this in the data type class'
      end

      def any_of(list)
        {
          anyOf: list
        }
      end

      private

      def ptype_short_name(clsname)
        clsname.to_s.split('::')[-1]
      end

      def puppet_type(type)
        raise "Not a Puppet data type, got #{type.class}" unless type.is_a?(Puppet::Pops::Types::PAnyType)

        pname = ptype_short_name(type.class)
      end
    end
  end
end
