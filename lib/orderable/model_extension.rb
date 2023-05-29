# frozen_string_literal: true

module Orderable
  module ModelExtension
    def orderable(field, scope: [], validate: true, default_push_front: true, scope_name: :ordered)
      executor = Executor.new(self, field, scope)

      class_eval do
        set_orderable_callbacks(executor, default_push_front)
        set_orderable_validations(field, executor) if validate
        scope scope_name, -> { order(*scope, field => :desc) }
      end

      define_singleton_method(:"reset_#{field}") { executor.reset }
    end

    private

    def set_orderable_callbacks(executor, default_push_front)
      after_initialize { executor.on_initialize(self) } if default_push_front
      before_create { executor.on_create(self) }
      before_update { executor.on_update(self) }
      before_destroy { reload }
      after_destroy { executor.on_destroy(self) }
    end

    def set_orderable_validations(field, executor)
      validates field, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
      validate { executor.validate_less_than_or_equal_to(self) }
    end
  end
end
