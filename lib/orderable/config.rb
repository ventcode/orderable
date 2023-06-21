# frozen_string_literal: true

require "ostruct"

module Orderable
  class Config < OpenStruct
    DEFAULTS = {
      field: nil,
      scope: [],
      validate: true,
      from: 0,
      direction: :asc,
      auto_set: true # find better name?
    }.freeze
    DIRECTIONS = %i[asc desc].freeze

    def initialize(**options)
      normalized_options = normalize_options!(options.dup)
      super(DEFAULTS.merge(normalized_options))
    end

    private

    def normalize_options!(options)
      options.tap do |o|
        o[:scope] = [o[:scope]] if o.key?(:scope) && !o[:scope].is_a?(Array)
        o[:direction] = :asc if o.key?(:direction) && !o[:direction].in?(DIRECTIONS)
      end
    end
  end
end
