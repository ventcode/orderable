# frozen_string_literal: true

module Orderable
  module ModelExtension
    def orderable(field, scope: [])
      return unless column_for_attribute(field).type == :integer

      class_eval do
        before_create { Executor.new(self, field, scope).expand }
        before_update { Executor.new(self, field, scope).shift }
        after_destroy { Executor.new(self, field, scope).collapse }
      end
    end
  end
end
