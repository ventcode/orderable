# frozen_string_literal: true

# require_relative 'executor'
module Orderable
  module ModelExtension
    # rubocop:disable Metrics/MethodLength, Metrics/AbcSize

    def orderable(field, scope: [], validate: true, default_push_last: true)
      executor = Executor.new(self, field, scope)

      class_eval do
        after_initialize { executor.on_initialize(self) } if default_push_last
        before_create { executor.on_create(self) }
        before_update { executor.on_update(self) }
        before_destroy { reload }
        after_destroy { executor.on_destroy(self) }

        return unless validate

        validates field, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
        self.validate { executor.validate_less_than_or_equal_to(self) }
      end
      define_singleton_method(:"reset_#{field}") { executor.reset }
    end
    # rubocop:enable Metrics/MethodLength, Metrics/AbcSize
  end
end
