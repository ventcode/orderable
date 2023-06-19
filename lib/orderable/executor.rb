# frozen_string_literal: true

module Orderable
  class Executor
    SEQUENCE_NAME = "orderable"

    attr_reader :model, :field, :scope, :auto_set, :from

    def initialize(model:, config:)
      @model = model
      @from = config.from
      @field = config.field.to_s
      @scope = config.scope.is_a?(Array) ? config.scope : [config.scope]
      @auto_set = config.auto_set
    end

    def on_create(record)
      return reposition_to_front(record) if auto_set && record[field].nil?

      records = affected_records(record, above: record[field])
      push(records)
    end

    def on_update(record)
      return unless orderable_index_affected?(record)
      return push_to_another_scope(record) if scope_affected?(record)

      above, below = record.changes[field].sort
      by = record.changes[field].reduce(&:<=>)

      records = affected_records(record, above: above, below: below)
      push(records, by: by)
    end

    def on_destroy(record)
      records = affected_records(record, above: record[field])
      push(records, by: -1)
    end

    def validate_less_than_or_equal_to(record) # rubocop:disable Metrics/AbcSize
      return if auto_set && record[field].nil?

      affected_records = affected_records(record)
      return if affected_records.size.zero?

      max_value = affected_records.maximum(field)
      max_value += 1 unless record.persisted?
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

    def orderable_index_affected?(record)
      (record.changed.map(&:to_sym) & ([field.to_sym] | scope)).present?
    end

    def scope_affected?(record)
      (scope & record.changed.map(&:to_sym)).present?
    end

    def affected_records(record, above: nil, below: nil)
      raise(AttributeError, field) unless model.column_for_attribute(field).type == :integer

      records = model.where(scope_query(record))
      records = records.where("#{field} >= ?", above) if above
      records = records.where("#{field} <= ?", below) if below
      records.all
    end

    def scope_query(record)
      scope.index_with { |scope_field| record[scope_field.to_s] }
    end

    def push_to_another_scope(record)
      adjust_in_previous_scope(record)
      return reposition_to_front(record) if auto_set && record.changes[field]&.second.nil?

      adjust_in_current_scope(record)
    end

    def adjust_in_current_scope(record)
      records = affected_records(record, above: record[field])
      push(records)
    end

    def adjust_in_previous_scope(record)
      previous_scope_attributes = attributes_before_update(record)
      records = affected_records(previous_scope_attributes, above: previous_scope_attributes[field])
      push(records, by: -1)
    end

    def attributes_before_update(record)
      record.attributes.merge(record.changes.transform_values(&:first))
    end

    def reposition_to_front(record)
      max_value = model.where(scope_query(record)).maximum(field)
      return record[field] = from if max_value.nil?

      record[field] = max_value + 1
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

      model.connection.execute("CREATE TEMP SEQUENCE #{SEQUENCE_NAME} MINVALUE #{from}")

      collection.each_with_index do |element, index|
        model.connection.execute("ALTER SEQUENCE #{SEQUENCE_NAME} RESTART") unless index.zero?
        yield(element)
      end

      model.connection.execute("DROP SEQUENCE #{SEQUENCE_NAME}")
    end
  end
end
