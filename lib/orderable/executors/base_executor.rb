# frozen_string_literal: true

module Orderable
  module Executors
    class BaseExecutor
      SEQUENCE_NAME = "orderable"

      attr_reader :model, :config

      delegate :field, :from, :direction, :auto_set, :scope, to: :config

      def initialize(model:, config:)
        @config = config
        @model = model
      end

      def on_create(record)
        return set_record_on_top(record) if auto_set && record[field].nil?

        records = affected_records(record, above: record[field])
        push(records)
      end

      def on_update(record) # rubocop:disable Metrics/AbcSize
        return unless orderable_index_affected?(record)
        return push_to_another_scope(record) if scope_affected?(record)

        above, below = record.changes[field].sort { |a, b| step * a <=> step * b }
        by = record.changes[field].reduce(&:<=>)

        records = affected_records(record, above: above, below: below)
        push(records, by: by)
      end

      def on_destroy(record)
        records = affected_records(record, above: record[field])
        push(records, by: -step)
      end

      def validate_record_position
        raise NotImplementedError
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

      def affected_records
        raise NotImplementedError
      end

      def scope_query(record)
        scope.map { |scope_field| [scope_field, record[scope_field.to_s]] }.to_h
      end

      def push_to_another_scope(record) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
        model.transaction do
          adjust_in_previous_scope(record)

          if auto_set && record.changes[field]&.second.nil? &&
             attributes_before_update(record)[field.to_s] != record[field]
            set_record_on_top(record)
          elsif auto_set && !record.send("#{field}_came_from_user?")
            set_record_on_top(record)
          else
            adjust_in_current_scope(record)
          end
        end
      end

      def adjust_in_current_scope(record)
        records = affected_records(record, above: record[field])
        push(records)
      end

      def adjust_in_previous_scope(record)
        previous_scope_attributes = attributes_before_update(record)
        records = affected_records(previous_scope_attributes, above: previous_scope_attributes[field.to_s])
        records = records.where.not(previous_scope_attributes)
        push(records, by: -step)
      end

      def attributes_before_update(record)
        record.attributes.merge(record.changes.transform_values(&:first))
      end

      def set_record_on_top
        raise NotImplementedError
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
        self.class::STEP
      end
    end
  end
end
