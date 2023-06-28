# frozen_string_literal: true

require "ostruct"

module Orderable
  class Config < OpenStruct
    DEFAULTS = {
      field: nil,
      scope: [],
      validate: true,
      from: 0,
      sequence: :incremental,
      auto_set: true
    }.freeze
    SEQUENCES = {
      incremental: :desc,
      decremental: :asc
    }.freeze

    def initialize(**options)
      normalized_options = normalize_options!(options)
      super(DEFAULTS.merge(normalized_options))
    end

    private

    def normalize_options!(options)
      options[:scope] = [options[:scope]] if options.key?(:scope) && !options[:scope].is_a?(Array)
      options.delete(:sequence) if options.key?(:sequence) && !SEQUENCES.key?(options[:sequence])
      options
    end
  end
end
