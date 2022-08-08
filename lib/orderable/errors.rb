# frozen_string_literal: true

module Orderable
  class AttributeError < StandardError
    def initialize(field)
      super("The field '#{field}' is not a supported data type (integer)")
    end
  end

  class AdapterError < StandardError
    def initalize(adapter)
      super("This operation is not supported for '#{adapter}' database adapter")
    end
  end
end
