# frozen_string_literal: true

module Orderable
  module ModelExtension
    def orderable(field, scope: [], validate: true, default_push_last: true)
      executor = Executor.new(self, field, scope)
      class_eval do
        set_orderable_callbacks(executor, default_push_last)
        set_orderable_validations(field, executor) if validate
      end
      define_singleton_method(:"reset_#{field}") { executor.reset }
    end

    private

    def set_orderable_callbacks(executor, default_push_last)
      after_initialize { executor.on_initialize(self) } if default_push_last
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
