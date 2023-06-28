# frozen_string_literal: true

RSpec.describe "Performance with index" do
  before(:all) do
    attrs = (0...100_000).to_a.map do |position|
      "('#{SecureRandom.alphanumeric(8)}', #{position})"
    end

    BasicModel.connection.execute(<<-SQL)
      ALTER TABLE basic_models
      DROP CONSTRAINT basic_models_position_key;

      INSERT INTO basic_models (name, position)
      VALUES
        #{attrs.join(', ')};
    SQL
  end

  after(:all) do
    BasicModel.delete_all
    BasicModel.connection.execute(<<-SQL)
      ALTER TABLE basic_models
      ADD UNIQUE(position) DEFERRABLE INITIALLY DEFERRED;
    SQL
  end

  describe "model without scope" do
    context "on #update" do
      subject { create(:basic_model).update!(position: position) }

      context "with position set as first value" do
        let(:position) { 0 }

        it "takes less than 0.9s" do
          expect(elapsed_time { subject }).to be < 0.9
        end
      end

      context "with position set as middle value" do
        let(:position) { 50_000 }

        it "takes less than 0.5s" do
          expect(elapsed_time { subject }).to be < 0.5
        end
      end

      context "with position set as last value" do
        let(:position) { 99_999 }

        it "takes less than 0.09s" do
          expect(elapsed_time { subject }).to be < 0.09
        end
      end
    end

    context "on #create" do
      subject { create(:basic_model, **attrs) }
      let(:attrs) { {} }

      context "without position specified" do
        it "takes less than 0.04s" do
          expect(elapsed_time { subject }).to be < 0.04
        end
      end

      context "with postion set as 3/4 of total count" do
        let(:attrs) { { position: 75_000 } }

        it "takes less than 0.25s" do
          expect(elapsed_time { subject }).to be < 0.25
        end
      end

      context "with position set as the middle value" do
        let(:attrs) { { position: 50_000 } }

        it "takes less than 0.5s" do
          expect(elapsed_time { subject }).to be < 0.5
        end
      end

      context "with position set as first value" do
        let(:attrs) { { position: 0 } }

        it "takes less than 0.9s" do
          expect(elapsed_time { subject }).to be < 0.9
        end
      end
    end

    context "on #destroy" do
      subject { record.destroy! }
      let!(:record) { create(:basic_model, **attrs) }

      context "with position set as last value" do
        let(:attrs) { { position: 100_000 } }

        it "takes less than 0.025s" do
          expect(elapsed_time { subject }).to be < 0.025
        end
      end

      context "with position set as middle value" do
        let(:attrs) { { position: 50_000 } }

        it "takes less than 0.6s" do
          expect(elapsed_time { subject }).to be < 0.6
        end
      end

      context "with position set as first value" do
        let(:attrs) { { position: 0 } }

        it "takes less than 1.15s" do
          expect(elapsed_time { subject }).to be < 1.15
        end
      end
    end
  end
end
