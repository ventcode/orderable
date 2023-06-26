# frozen_string_literal: true

module Orderable
  class Executor
    SEQUENCE_NAME = "orderable"
    SEQUENCE_STEPS = {
      incremental: 1,
      decremental: -1
    }.freeze

    attr_reader :model, :config

    delegate :field, :from, :sequence, :auto_set, :scope, to: :config

    def initialize(model:, config:)
      @config = config
      @model = model
    end

    def on_create(record)
      return set_record_on_top(record) if auto_set && record[field].nil?

      records = affected_records(record, above: record[field])
      push(records)
    end

    def on_update(record)
      return unless orderable_index_affected?(record)
      return push_to_another_scope(record) if scope_affected?(record)

      sorted_changes = record.changes[field].sort
      above, below = sequence == :incremental ? sorted_changes : sorted_changes.reverse
      by = record.changes[field].reduce(&:<=>)

      records = affected_records(record, above: above, below: below)
      push(records, by: by)
    end

    def on_destroy(record)
      records = affected_records(record, above: record[field])
      push(records, by: -step)
    end

    def validate_record_position(record)
      return if auto_set && record[field].nil?

      top_position = find_top_position(record)
      return if top_position.nil?

      range = [from, top_position].sort
      return if record[field]&.between?(*range)

      record.errors.add(field, :inclusion, message: "should be between #{range.join(' and ')}")
    end

    def numericality_validation
      return { only_integer: true, greater_than_or_equal_to: from }.freeze if sequence.eql?(:incremental)

      { only_integer: true, less_than_or_equal_to: from }.freeze
    end

    def reset
      raise(AdapterError, model.connection.adapter_name) if model.connection.adapter_name != "PostgreSQL"

      with_sequence(scope_groups) do |scope_group|
        model.where(scope_group).order(field).update_all("#{field} = nextval('#{SEQUENCE_NAME}')")
      end
    end

    private

    def orderable_index_affected?(record)
      (record.changed.map(&:to_sym) & ([field] | scope)).any?
    end

    def scope_affected?(record)
      (scope & record.changed.map(&:to_sym)).any?
    end

    def add_validation_error; end

    def affected_records(record, above: nil, below: nil)
      raise(AttributeError, field) if model.column_for_attribute(field).type != :integer

      above, below = below, above if sequence == :decremental
      records = model.where(scope_query(record))
      records = records.where("#{field} >= ?", above) if above
      records = records.where("#{field} <= ?", below) if below
      records.all
    end

    def scope_query(record)
      scope.map { |scope_field| [scope_field, record[scope_field.to_s]] }.to_h
    end

    def push_to_another_scope(record)
      adjust_in_previous_scope(record)
      if auto_set && field_not_changed?(record)
        set_record_on_top(record)
      else
        adjust_in_current_scope(record)
      end
    end

    def field_not_changed?(record)
      return if record.changes[field]&.second.present?

      !(record.send("#{field}_came_from_user?") && attributes_before_update(record)[field.to_s] == record[field])
    end

    def adjust_in_current_scope(record)
      records = affected_records(record, above: record[field])
      push(records)
    end

    def adjust_in_previous_scope(record)
      previous_scope_attributes = attributes_before_update(record)
      records = affected_records(previous_scope_attributes, above: previous_scope_attributes[field.to_s] + step)
      push(records, by: -step)
    end

    def attributes_before_update(record)
      record.attributes.merge(record.changes.transform_values(&:first))
    end

    def set_record_on_top(record)
      records = model.where(scope_query(record))
      top_position = records.send(extremum, field)
      return record[field] = from if top_position.blank?

      record[field] = top_position + step
    end

    def find_top_position(record)
      position = affected_records(record).send(extremum, field)
      return if position.nil?

      record.persisted? ? position : position + step
    end

    def push(records, by: step)
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

    def step
      @step ||= SEQUENCE_STEPS[sequence]
    end

    def extremum
      @extremum ||= sequence.eql?(:incremental) ? :maximum : :minimum
    end
  end
end
