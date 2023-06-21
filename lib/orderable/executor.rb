# frozen_string_literal: true

module Orderable
  class Executor
    SEQUENCE_NAME = "orderable"
    DIRECTION_EXTREMA = {
      asc: {
        type: :maximum,
        step: 1
      },
      desc: {
        type: :minimum,
        step: -1
      }
    }.freeze
    private_constant :DIRECTION_EXTREMA

    attr_reader :model, :config

    delegate :field, :from, :direction, :auto_set, :scope, to: :config

    def initialize(model:, config:)
      @config = config
      @model = model
    end

    # front -  if asc - front <= from, if desc - front >= from
    # top - if asc - the highers number, if desc - the lowest number
    def on_create(record)
      return set_record_on_top(record) if auto_set && record[field].nil?

      records = if direction == :asc
                  affected_records(record, above: record[field])
                else
                  affected_records(record, below: record[field]) # przeszkadza
                end

      push(records)
    end

    def on_update(record)
      return unless orderable_index_affected?(record)
      return push_to_another_scope(record) if scope_affected?(record)

      above, below = record.changes[field].sort
      by = record.changes[field].reduce(&:<=>)

      records = affected_records(record, above: above, below: below) # przeszkadza
      push(records, by: by)
    end

    def on_destroy(record)
      records = if direction == :asc
                  affected_records(record, above: record[field])
                else
                  affected_records(record, below: record[field])
                end

      push(records, by: -DIRECTION_EXTREMA.fetch(direction, :asc)[:step])
    end

    def validate_less_than_or_equal_to(record) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
      return if auto_set && record[field].nil?

      affected_records = affected_records(record)
      return if affected_records.size.zero?

      extremum = DIRECTION_EXTREMA.fetch(direction, :asc)
      extreme_value = affected_records.send(extremum[:type], field)
      extreme_value += extremum[:step] unless record.persisted?
      return if record[field] && extremum[:type] == :maximum && record[field] <= extreme_value
      return if record[field] && extremum[:type] == :minimum && record[field] >= extreme_value

      record.errors.add(field, :less_than_or_equal_to, count: extreme_value)
    end # źle

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

    def affected_records(record, above: nil, below: nil)
      raise(AttributeError, field) unless model.column_for_attribute(field).type == :integer

      records = model.where(scope_query(record))
      records = records.where("#{field} >= ?", above) if above
      records = records.where("#{field} <= ?", below) if below
      records.all
    end

    def scope_query(record)
      # TODO: Error that scope does not exists
      scope.index_with { |scope_field| record[scope_field.to_s] }
    end

    def push_to_another_scope(record)
      model.transaction do # add test for transaction
        adjust_in_previous_scope(record)

        if auto_set && record.changes[field]&.second.nil?
          set_record_on_top(record)
        else
          adjust_in_current_scope(record)
        end
      end
    end

    def adjust_in_current_scope(record) # add test for direction
      records = affected_records(record, above: record[field])
      push(records)
    end

    def adjust_in_previous_scope(record) # add test for direction
      previous_scope_attributes = attributes_before_update(record)
      records = affected_records(previous_scope_attributes, above: previous_scope_attributes[field.to_s])
      push(records, by: -1)
    end

    def attributes_before_update(record)
      record.attributes.merge(record.changes.transform_values(&:first))
    end

    def set_record_on_top(record)
      records_scope = model.where(scope_query(record))
      extremum = DIRECTION_EXTREMA.fetch(direction, :asc)
      extreme_value = records_scope.send(extremum[:type], field)
      return record[field] = from if extreme_value.nil?

      record[field] = extreme_value + extremum[:step]
    end

    def push(records, by: DIRECTION_EXTREMA.fetch(direction, :asc)[:step])
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
