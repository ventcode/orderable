# frozen_string_literal: true

module Orderable
  module ModelExtension
    def orderable(field, scope: [], validate: true, default_push_front: true, scope_name: :ordered,
                  order: :desc)
      executor = Executor.new(self, field, scope, default_push_front: default_push_front)

      class_eval do
        set_orderable_callbacks(executor)
        set_orderable_validations(executor) if validate
        scope scope_name, -> { order(*scope, field => order) }
      end

      define_singleton_method(:"reset_#{field}") { executor.reset }
    end

    private

    # rubocop:disable Naming/AccessorMethodName
    def set_orderable_callbacks(executor)
      before_create { executor.on_create(self) }
      before_update { executor.on_update(self) }
      before_destroy { reload }
      after_destroy { executor.on_destroy(self) }
    end

    def set_orderable_validations(executor)
      validates executor.field, presence: true unless executor.default_push_front
      validates executor.field, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true
      validate { executor.validate_less_than_or_equal_to(self) }
    end
    # rubocop:enable Naming/AccessorMethodName
  end
end
