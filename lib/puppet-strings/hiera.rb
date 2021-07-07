# frozen_string_literal: true

module PuppetStrings
  module Hiera
    require_relative 'hiera/hierarchy_data_path'
    require_relative 'hiera/data'

    def self.load_config
      PuppetStrings::Hiera::Data.new('hiera.yaml')
    end
  end
end
