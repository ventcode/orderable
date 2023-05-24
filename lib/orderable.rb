# frozen_string_literal: true

require "active_record"

require_relative "orderable/version"
require_relative "orderable/model_extension"
require_relative "orderable/executor"
require_relative "orderable/errors"

module Orderable
  ActiveSupport.on_load(:active_record) { extend Orderable::ModelExtension }
end
