# frozen_string_literal: true

module Orderable
  class Executor
    SEQUENCE_NAME = "orderable"

    attr_reader :model, :field, :scope

    def initialize(model, field, scope)
      @model = model
      @field = field.to_s
      @scope = scope.is_a?(Array) ? scope : [scope]
    end

    def on_initialize(record)
      record[field] ||= affected_records(record).count
    end

    def on_create(record)
      records = affected_records(record, above: record[field])
      push(records)
    end

    def on_update(record)
      return unless record.changed.include?(field)

      above, below = record.changes[field].sort
      by = record.changes[field].reduce(&:<=>)

      records = affected_records(record, above: above, below: below)
      push(records, by: by)
    end

    def on_destroy(record)
      records = affected_records(record, above: record[field])
      push(records, by: -1)
    end

    def validate_less_than_or_equal_to(record)
      max_value = affected_records(record).count
      max_value -= 1 unless record.new_record?
      return if record[field] && record[field] <= max_value

      record.errors.add(field, :less_than_or_equal_to, count: max_value)
    end

    def reset
      raise(AdapterError, model.connection.adapter_name) if model.connection.adapter_name != "PostgreSQL"

      with_sequence(scope_groups) do |scope_group|
        model.where(scope_group).order(field).update_all("#{field} = nextval('#{SEQUENCE_NAME}')")
      end
    end

    private

    def affected_records(record, above: nil, below: nil)
      raise(AttributeError, field) unless model.column_for_attribute(field).type == :integer

      records = model.where(scope_query(record))
      records = records.where("#{field} >= ?", above) if above
      records = records.where("#{field} <= ?", below) if below
      records.all
    end

    def scope_query(record)
      scope.index_with { |scope_field| record[scope_field] }
    end

    def push(records, by: 1)
      records.update_all("#{field} = #{field} + #{by}")
    end

    def scope_groups
      return [nil] if scope.empty?

      model.group(scope).count.map do |(values, _count)|
        values = [values] unless values.is_a?(Array)
        scope.zip(values).to_h
      end
    end

    def with_sequence(collection)
      return unless block_given?

      model.connection.execute("CREATE TEMP SEQUENCE #{SEQUENCE_NAME} MINVALUE 0")

      collection.each_with_index do |element, index|
        model.connection.execute("ALTER SEQUENCE #{SEQUENCE_NAME} RESTART") unless index.zero?
        yield(element)
      end

      model.connection.execute("DROP SEQUENCE #{SEQUENCE_NAME}")
    end
  end
end
