# frozen_string_literal: true

module Orderable
  module ModelExtension
    # rubocop:disable Metrics/MethodLength
    def orderable(field, scope: [], validate: true, default_push_last: true)
      executor = Executor.new(self, field, scope)

      class_eval do
        after_initialize { executor.put_field_for_last(self) } if default_push_last
        before_create { executor.on_create(self) }
        before_update { executor.on_update(self) }
        after_destroy { executor.on_destroy(self) }

        return unless validate

        validates field, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
        self.validate { executor.validate_less_than_or_equal_to(self) }
      end

      define_singleton_method(:"reset_#{field}") { executor.reset }
    end
    # rubocop:enable Metrics/MethodLength
  end
end
