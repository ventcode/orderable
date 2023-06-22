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
      normalized_options = normalize_options!(options.dup)
      super(DEFAULTS.merge(normalized_options))
    end

    def order_direction
      SEQUENCES.fetch(sequence)
    end

    private

    def normalize_options!(options)
      options.tap do |o|
        o[:scope] = [o[:scope]] if o.key?(:scope) && !o[:scope].is_a?(Array)
        o.delete(:sequence) if o.key?(:sequence) && !SEQUENCES.key?(o[:sequence])
      end
    end
  end
end
