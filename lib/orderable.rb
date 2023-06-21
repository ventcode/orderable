# frozen_string_literal: true

require "active_record"

require_relative "orderable/version"
require_relative "orderable/model_extension"
require_relative "orderable/config"
require_relative "orderable/executors/base_executor"
require_relative "orderable/executors/incremental"
require_relative "orderable/executors/decremental"
require_relative "orderable/errors"

module Orderable
  ActiveSupport.on_load(:active_record) { extend Orderable::ModelExtension }
end
