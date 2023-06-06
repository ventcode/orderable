# frozen_string_literal: true

module Orderable
  module ModelExtension
    def orderable(field, **options)
      config = Config.new(field: field, **options)
      executor = Executor.new(model: self, config: config) # adjust executor

      class_eval do
        before_create { executor.on_create(self) }
        before_update { executor.on_update(self) }
        after_destroy { executor.on_destroy(self) }

        before_destroy { reload } # check if there is a way to avoid this

        if config.validate
          validates field, presence: true unless config.auto_set
          validates field, numericality: {
            only_integer: true,
            greater_than_or_equal_to: config.from
          }, allow_nil: true

          validate { executor.validate_less_than_or_equal_to(self) }
        end

        scope :ordered, ->(direction = :asc) { order(field => direction) }

        def reorder
          executor.reset
        end
      end
    end
  end
end
