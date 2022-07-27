# frozen_string_literal: true

module Orderable
  class Executor
    attr_reader :record, :field, :value, :scope

    def initialize(record, field, scope)
      @record = record
      @field = field.to_s
      @value = record[field]
      @scope = scope.is_a?(Array) ? scope : [scope]
    end

    def expand
      records = affected_records(above: value)
      push(records)
    end

    def shift
      return unless record.changed.include?(field)

      above, below = record.changes[field].sort
      by = record.changes[field].reduce(&:<=>)

      records = affected_records(above: above, below: below)
      push(records, by: by)
    end

    def collapse
      records = affected_records(above: value)
      push(records, by: -1)
    end

    private

    def affected_records(above: nil, below: nil)
      records = record.class
      records = records.where(scope_query) if scope.present?
      records = records.where("#{field} >= ?", above) if above
      records = records.where("#{field} <= ?", below) if below
      records.all
    end

    def scope_query
      scope.index_with { |scope_field| record[scope_field] }
    end

    def push(records, by: 1)
      records.update_all("#{field} = #{field} + #{by}")
    end
  end
end
