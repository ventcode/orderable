# frozen_string_literal: true

module Orderable
  module ModelExtension
    def orderable(field, **options) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      config = Config.new(field: field, **options)

      executor = if config.direction == :asc
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
          validates field, allow_nil: true, numericality: {
            only_integer: true
          }.merge!(
            if config.direction == :asc
              { greater_than_or_equal_to: config.from }
            else
              { less_than_or_equal_to: config.from }
            end
          )

          validate { executor.validate_record_position(self) }
        end

        scope :ordered, ->(direction = :desc) { order(field => direction) }
        define_singleton_method(:reorder) { executor.reset }
      end
    end
  end
end
