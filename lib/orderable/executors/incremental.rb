# frozen_string_literal: true

module Orderable
  module Executors
    class Incremental < BaseExecutor
      STEP = 1

      def validate_record_position(record) # rubocop:disable Metrics/AbcSize
        return if auto_set && record[field].nil?

        max_position = affected_records(record).maximum(field)
        return if max_position.nil?

        max_position += STEP unless record.persisted?
        return if record[field] && record[field] <= max_position

        record.errors.add(field, :less_than_or_equal_to, count: max_position)
      end

      private

      def affected_records(record, above: nil, below: nil)
        raise(AttributeError, field) unless model.column_for_attribute(field).type == :integer

        records = model.where(scope_query(record))
        records = records.where("#{field} >= ?", above) if above
        records = records.where("#{field} <= ?", below) if below
        records.all
      end

      def set_record_on_top(record)
        records = model.where(scope_query(record))
        max_position = records.send(:maximum, field)
        return record[field] = from if max_position.blank?

        record[field] = max_position + STEP
      end
    end
  end
end
