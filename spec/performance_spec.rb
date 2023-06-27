# frozen_string_literal: true

require "benchmark"
# TODO: Turn off performance-related tests during pipeline execution
RSpec.describe "Performance" do
  describe "model without scope" do
    context "on #update" do
      subject do
        create(:basic_model, name: "target").update!(position: 0)
      end

      before do
        attrs = (0...500_000).to_a.map do |position|
          "('#{SecureRandom.alphanumeric(8)}', #{position})"
        end

        BasicModel.connection.execute(<<-SQL)
          INSERT INTO basic_models (name, position)
          VALUES
            #{attrs.join(', ')};
        SQL
      end

      let(:offset) { rand(1..500) }
      let!(:expected_result) do
        BasicModel.ordered(:asc).offset(offset).first(10).pluck(:name, :position).to_h
                  .transform_values { |v| v + 1 }
      end

      it "shifts the records" do
        exec_time = Benchmark.measure { subject }
        # TODO: Check object allocation
        expect(exec_time.real).to be < 6.8
        expect(BasicModel.ordered(:asc).offset(offset + 1).first(10).pluck(:name, :position).to_h)
          .to eq(expected_result)
      end
    end
  end
end
