# frozen_string_literal: true

module Orderable
  module Executors
    class Decremental < BaseExecutor
      STEP = -1

      def validate_record_position(record) # rubocop:disable Metrics/AbcSize
        return if auto_set && record[field].nil?

        min_position = affected_records(record).minimum(field)
        return if min_position.nil?

        min_position += STEP unless record.persisted?
        return if record[field] && record[field] >= min_position

        record.errors.add(field, :greater_than_or_equal_to, count: min_position)
      end

      def numericality_validation
        { only_integer: true, less_than_or_equal_to: from }.freeze
      end

      private

      def affected_records(record, above: nil, below: nil)
        raise(AttributeError, field) unless model.column_for_attribute(field).type == :integer

        records = model.where(scope_query(record))
        records = records.where("#{field} <= ?", above) if above
        records = records.where("#{field} >= ?", below) if below
        records.all
      end

      def set_record_on_top(record)
        records = model.where(scope_query(record))
        min_position = records.minimum(field)
        return record[field] = from if min_position.blank?

        record[field] = min_position + STEP
      end
    end
  end
end
