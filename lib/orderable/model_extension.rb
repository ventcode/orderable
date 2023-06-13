# frozen_string_literal: true

module Orderable
  module ModelExtension
    def orderable(field, **options) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      config = Config.new(field: field, **options)
      executor = Executor.new(model: self, config: config)

      class_eval do
        before_create { executor.on_create(self) }
        before_update { executor.on_update(self) }
        after_destroy { executor.on_destroy(self) }
        # TODO: Check if there is a way to avoid reload
        before_destroy { reload }

        if config.validate
          validates field, presence: true, on: :update
          validates field, presence: true, on: :create unless config.auto_set
          validates field, numericality: {
            only_integer: true,
            greater_than_or_equal_to: config.from
          }, allow_nil: true

          validate { executor.validate_less_than_or_equal_to(self) }
        end

        scope :ordered, ->(direction = :desc) { order(field => direction) }
        define_singleton_method(:reorder) { executor.reset }
      end
    end
  end
end
