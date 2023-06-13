# frozen_string_literal: true

require "ostruct"

module Orderable
  class Config < OpenStruct
    DEFAULTS = {
      field: nil,
      scope: [],
      validate: true,
      from: 0,
      step: 1,
      auto_set: true # find better name?
    }.freeze

    def initialize(**options)
      super(DEFAULTS.merge(options))
    end
  end
end
