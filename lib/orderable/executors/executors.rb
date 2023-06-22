# frozen_string_literal: true

module Orderable
  module Executors
    EXECUTORS = {
      incremental: Incremental,
      decremental: Decremental
    }.freeze
    private_constant :EXECUTORS

    def self.get(sequence)
      EXECUTORS[sequence]
    end
  end
end
