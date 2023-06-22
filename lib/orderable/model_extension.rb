# frozen_string_literal: true

module Orderable
  module ModelExtension
    def orderable(field, **options) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      config = Config.new(field: field, **options)

      executor = if config.sequence == :incremental
                   Executors::Incremental.new(model: self, config: config)
                 else
                   Executors::Decremental.new(model: self, config: config)
                 end

      class_eval do
        before_create { executor.on_create(self) }
        before_update { executor.on_update(self) }
        after_destroy { executor.on_destroy(self) }
        # TODO: Check if there is a way to avoid reload
        before_destroy { reload }

        if config.validate
          validates field, presence: true, on: :update
          validates field, presence: true, on: :create unless config.auto_set
          validates field, allow_nil: true, numericality: executor.numericality_validation

          validate { executor.validate_record_position(self) }
        end

        scope :ordered, ->(direction = config.order_direction) { order(field => direction) }
        define_singleton_method(:reorder) { executor.reset }
      end
    end
  end
end
